defmodule SimplePlugRest.Application do
  @moduledoc false

  use Application
  require :logger
  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: SimplePlugRest, options: [port: 5000]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SimplePlugRest.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
