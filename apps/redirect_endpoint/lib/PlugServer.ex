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
    send(:main, {:code, fetch_query_params(conn).query_params["code"]})
    conn
    |> put_resp_content_type("text/plain")
    #|> send_resp(200,"accepted")
    |> send_resp(200, Kernel.inspect(fetch_query_params(conn).query_params))


  end
end
