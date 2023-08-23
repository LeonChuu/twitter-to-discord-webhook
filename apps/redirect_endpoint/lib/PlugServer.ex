defmodule SimplePlugRest do
  @moduledoc """
  A Plug that always responds with a string
  """
  import Plug.Conn
  require Logger

  def init(options) do
    Logger.info("starting SimplePlugRest")
    options
  end

  @doc """
  Simple route that returns a string
  """
  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(conn, opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, Kernel.inspect(fetch_query_params(conn).query_params))
  end
end
"""
    client = OAuth2.Client.new([
      strategy: OAuth2.Strategy.AuthCode, #default
      client_id: config.client_id,
      client_secret: config.client_secret,
      site: config.auth_url,
      redirect_uri: config.redirect_uri
    ])
    OAuth2.Client.authorize_url!(client)
    client = OAuth2.Client.get_token!(client, code: "someauthcode")
"""
