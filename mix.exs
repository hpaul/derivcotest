defmodule Derivcotest.MixProject do
  use Mix.Project

  def project do
    [
      app: :derivcotest,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Derivcotest.App, []},
      applications: [:plug_cowboy, :poison, :cowboy, :exprotobuf],
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.1"},
      {:poison, "~> 4.0"},
      {:exprotobuf, "~> 1.2"},
      {:remix, "~> 0.0.1", only: :dev}
    ]
  end
end
