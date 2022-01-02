defmodule Simplehook do
  use Application
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
    # IO.inspect(encoded_url)
    headers  = ["Authorization": "Bearer " <> config.twitter_bearer_token]
    output = HTTPoison.get!(encoded_url, headers)
    # Poison.Parser.parse!(output.body, %{keys: :atoms!})
    decoded = Poison.decode!(output.body)
    current_date = DateTime.to_iso8601(DateTime.now!("Etc/UTC"))
    if(decoded["data"] != nil) do
      Enum.each(decoded["data"],
      fn (data) ->
        Enum.each(data["entities"]["urls"], fn(url) ->
          content = Poison.encode!(%{"content" => url["expanded_url"]})
          IO.inspect(url["expanded_url"])
          Enum.each(config.webhook_urls, fn webhook_url ->
            response = HTTPoison.post!(webhook_url, content , ["Content-Type": "application/json"])
            IO.inspect(response)
          end)
          # to avoid rate limiting
          :timer.sleep(1000)
        end)
      end)
    end
    :timer.sleep(config.poll_time_ms)
    listener(config, twitter_id, current_date)
  end

  def send_initialization_message(config) do
    Enum.each(config.webhook_urls, fn webhook_url ->
      response = HTTPoison.post!(webhook_url, Poison.encode!(%{"content" => "Ooee has awoken."}) , ["Content-Type": "application/json"])
      # IO.inspect(response)
    end)

  end

  def start(start_type, start_args) do
    HTTPoison.start()
    config=BotConfig.initialize()
    send_initialization_message(config)
    IO.inspect(config)
    Enum.each(config.twitter_ids, fn x -> listener(config, x) end)

    Supervisor.start_link [], strategy: :one_for_one
  end
end
