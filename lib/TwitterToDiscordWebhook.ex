defmodule TwitterToDiscordWebhook do
  use Application
  require Logger
  @moduledoc """
  Documentation for Simplehook.
  """

  @spec listen(
          atom
          | %{
              :poll_time_ms => :infinity | non_neg_integer,
              :twitter_bearer_token => binary,
              :webhook_urls => any,
              optional(any) => any
            },
          binary,
          any
        ) :: no_return
  @doc """
  Hello world.


  """


  def listen(config, url_base, current_date \\ nil) do

    datetime = DateTime.to_iso8601(DateTime.now!("Etc/UTC"))
    status = process(config, url_base, current_date)
    :timer.sleep(config.poll_time_ms)
    case status do
      :ok -> listen(config, url_base, datetime)
      :error -> listen(config, url_base, current_date)
    end
  end

  def process(config, url_base, current_date \\ nil) do

    response = get_tweets(config.twitter_bearer_token, url_base, current_date)
    Logger.debug(inspect(response))

    case response do
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        case status_code do
          x when x in 200..299 ->
            post_to_webhooks(body, config.webhook_urls)
          _ ->
            Logger.error("error getting from api: code" <> inspect(status_code))
            :error
        end
      _ ->
        Logger.error("error getting from api: " <> inspect(response))
        :error
      end

  end

  defp get_tweets(token, url_base, current_date) do
    url = if current_date != nil do
      url_base <> "&start_time=" <> current_date
    else
      url_base
    end

    Logger.debug("twitter id:" <> inspect(url_base))
    Logger.debug("date:" <> inspect(current_date))

    encoded_url = URI.encode(url)
    headers  = ["Authorization": "Bearer " <> token]
    HTTPoison.get(encoded_url, headers)
  end

  defp post_to_webhook(content, webhook_url) do
    {status, response} = HTTPoison.post(webhook_url, content , ["Content-Type": "application/json"])
      #checking for request success first, status code later.
    case status do
      :ok ->
        Logger.debug(inspect(response))
        case response do
          %HTTPoison.Response{status_code: status_code, body: body} ->
            case status_code do
              x when x in 200..299 -> true
              _ ->
                Logger.error("Error posting to webhook " <> inspect(body))
                false
            end
          _ ->
            Logger.error("Error posting to webhook.")
            false
        end
      :error -> false
    end
  end

  defp post_to_webhooks(body, webhook_urls)  do
    Logger.debug("posting to webhooks.")
    #each tweet in the period will be in a "data" field.
    result_status = with %{"data" => data} <- Poison.decode!(body), do:
      Enum.any?(Enum.map(data, fn (datum) ->
      with %{"entities" => %{"urls" => urls}} <- datum do

        if(Enum.empty?(urls)) do
          false
        else
          url = Enum.at(urls, 0)
          content = Poison.encode!(%{"content" => url["expanded_url"]})
          Logger.debug("expanded_url:" <> inspect(content))
          # to avoid rate limiting
          :timer.sleep(1000)

          #We post each tweet's content urls to each webhook.
          response_status = Enum.map(webhook_urls, fn webhook_url -> post_to_webhook(content, webhook_url ) end)
          Enum.any?(response_status)
        end
      end
    end))
    if result_status == true, do: :ok, else: :error
  end

  def send_initialization_message(config) do
    Enum.each(config.webhook_urls, fn webhook_url ->
      HTTPoison.post!(webhook_url, Poison.encode!(%{"content" => "Ooee has awoken."}) , ["Content-Type": "application/json"])
    end)
  end


  def start(_start_type, _start_args) do

    case System.get_env("LOG_LEVEL") do
      nil -> Logger.configure(level: :info)
      x -> Logger.configure(level: String.to_atom(x))
    end

    Logger.info("current logging level:" <> inspect(Logger.level()))
    initial_datetime = DateTime.now!("Etc/UTC")
    #{:ok, initial_datetime, _} = DateTime.from_iso8601("2022-08-10T00:00:00Z")

    HTTPoison.start()
    config = BotConfig.initialize()
    send_initialization_message(config)

    supervisor = Task.Supervisor
    {:ok, pid} = supervisor.start_link()
    Logger.info("Starting application.")
    children = [
    {Task, fn ->

      Logger.info("waiting for twitter's latest tweets time limit(10s)")
      #twitter requires prior time to be at least 10 seconds.
      :timer.sleep(10000)
      Logger.info("starting listeners:")
      Enum.map(config.twitter_ids,
      fn (id) ->
            url_base = "https://api.twitter.com/2/tweets/search/recent?query=from:" <> id <> " " <> config.base_query
            supervisor.async(pid, fn -> listen(config, url_base, DateTime.to_iso8601(initial_datetime))
          end)
        end)
      end}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
