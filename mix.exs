defmodule TwitterToDiscordWebhook.MixProject do
  use Mix.Project
  require Logger
  def project do
    [
      app: :twittertodiscordwebhook,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        release: [
          include_erts: true
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {TwitterToDiscordWebhook,[]},
      extra_applications: [:logger, :httpoison, :poison]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
    {:httpoison, "~> 1.8"},
    {:poison, "~> 5.0"},
    {:bypass, "~> 2.1"}
    ]
  end
end
