defmodule Simplehook.MixProject do
  use Mix.Project

  def project do
    [
      app: :twittertest,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        release: [
          include_erts: false
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Simplehook,[]},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
    {:httpoison, "~> 1.8"},
    {:poison, "~> 5.0"}
    ]
  end
end
