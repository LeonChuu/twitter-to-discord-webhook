require Logger
defmodule BotConfig do
  @default_base_query "has:media -is:retweet -is:quote &tweet.fields=entities"
  @default_poll_time "1800000"
  @default_redirect_uri "http://localhost:5000/auth/callback"
  @default_auth_url "https://twitter.com/i"
  @default_token_url "https://api.twitter.com/2"
  defstruct poll_time_ms: String.to_integer(@default_poll_time), twitter_ids: [], webhook_urls: [], twitter_bearer_token: nil, base_query: @default_base_query,
  client_id: nil, client_secret: nil, redirect_uri: @default_redirect_uri,
  auth_url: @default_auth_url, token_url: @default_token_url

  def new(twitter_ids, webhook_urls, poll_time_ms, twitter_bearer_token,
    base_query, client_id, client_secret, redirect_uri, auth_url, token_url) do

    %BotConfig{twitter_ids: twitter_ids, webhook_urls: webhook_urls, poll_time_ms: poll_time_ms,
      twitter_bearer_token: twitter_bearer_token, base_query: base_query, client_id: client_id,
       client_secret: client_secret, redirect_uri: redirect_uri, auth_url: auth_url, token_url: token_url}
  end

  def initialize() do

    twitter_ids_var = System.get_env("TWITTER_IDS")
    webhook_urls_var = System.get_env("WEBHOOK_URLS")
    twitter_bearer_token = System.get_env("TWITTER_BEARER_TOKEN")
    client_id = System.get_env("TWITTER_CLIENT_ID")
    client_secret = System.get_env("TWITTER_CLIENT_SECRET")


    webhook_urls = if webhook_urls_var == nil do
      raise "Set the WEBHOOK_URLS environment variable. Example: WEBHOOK_URLS=https://discord.com/api/webhooks/1234/abcde,https://discord.com/api/webhooks/1234/ghji"
    else
      Logger.debug("Splitting webhook_urls:" <> inspect(webhook_urls_var))
      String.split(webhook_urls_var, ",")
    end

    twitter_ids = if twitter_ids_var == nil do
      raise "Set the TWITTER_IDS environment variable. Example: TWITTER_IDS=123,456"
    else
      Logger.debug("Splitting twitter_ids:" <> inspect(twitter_ids_var))
      String.split(twitter_ids_var, ",")
    end

    if twitter_bearer_token == nil do
      raise "Set the TWITTER_BEARER_TOKEN environment_variable"
    end

    if client_id == nil do
      raise "Set the TWITTER_CLIENT_ID environment_variable"
    end

    if client_secret == nil do
      raise "Set the TWITTER_CLIENT_SECRET environment_variable"
    end

    BotConfig.new(twitter_ids, webhook_urls, String.to_integer(System.get_env("POLL_TIME_MS",@default_poll_time)),
      twitter_bearer_token, System.get_env("BASE_TWITTER_QUERY",@default_base_query), client_id, client_secret, System.get_env("REDIRECT_URI",@default_redirect_uri),
      System.get_env("TWITTER_AUTH_URL", @default_auth_url), System.get_env("TWITTER_TOKEN_URL", @default_token_url))
  end

end
