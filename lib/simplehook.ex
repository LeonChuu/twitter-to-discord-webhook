defmodule Simplehook do
  use Application
  require Logger
  @moduledoc """
  Documentation for Simplehook.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Simplehook.listener()
      :world

  """


  def listener(config, twitter_id, current_date \\ nil) do

    url_base = "https://api.twitter.com/2/tweets/search/recent?query=from:" <> twitter_id <>" has:media -is:retweet -is:quote &tweet.fields=entities"

      url = if current_date != nil do
        url_base <> "&start_time=" <> current_date
      else
        url_base
      end

    encoded_url = URI.encode(url)
    headers  = ["Authorization": "Bearer " <> config.twitter_bearer_token]
    response = HTTPoison.get(encoded_url, headers)
    current_date = DateTime.to_iso8601(DateTime.now!("Etc/UTC"))
    Logger.debug(inspect(response))
    case response do
      {:ok, %HTTPoison.Response{status_code: _status_code, body: body}} ->
          with %{"data" => data} <- Poison.decode!(body),
          do: Enum.each(data, fn (datum) ->
            with %{"entities" => %{"urls" => urls}} <- datum,
            do: Enum.each(urls, fn url ->
              content = Poison.encode!(%{"content" => url["expanded_url"]})
              Enum.each(config.webhook_urls, fn webhook_url ->
                response = HTTPoison.post!(webhook_url, content , ["Content-Type": "application/json"])
                Logger.debug(inspect(response))
              end)
              # to avoid rate limiting
              :timer.sleep(1000)
            end)
          end)
      _ -> Logger.error("error getting from api: " <> inspect(response))

    end

    :timer.sleep(config.poll_time_ms)
    listener(config, twitter_id, current_date)
  end

  def send_initialization_message(config) do
    Enum.each(config.webhook_urls, fn webhook_url ->
      HTTPoison.post!(webhook_url, Poison.encode!(%{"content" => "Ooee has awoken."}) , ["Content-Type": "application/json"])
    end)

  end

  def start(_start_type, _start_args) do
    initial_datetime = DateTime.now!("Etc/UTC")

    HTTPoison.start()
    config = BotConfig.initialize()
    send_initialization_message(config)
    Logger.info("config settings: " <> inspect(config))
    Logger.debug("current time: " <> inspect(initial_datetime))

    #twitter requires prior time to be at least 10 seconds.
    :timer.sleep(10000)
    tasks = Enum.map(config.twitter_ids,
      fn (id) -> Task.async(fn -> listener(config, id, DateTime.to_iso8601(initial_datetime))
     end)
    end)

    Task.await_many(tasks, :infinity)

    Supervisor.start_link [], strategy: :one_for_one
  end
end