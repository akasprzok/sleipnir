defmodule Sleipnir.MixProject do
  use Mix.Project

  @version "0.1.3"
  @url "https://github.com/akasprzok/sleipnir"

  def project do
    [
      app: :sleipnir,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      preferred_cli_env: preferred_cli_env(),
      description: description(),
      package: package(),
      source_url: @url,
      docs: docs(),

      # Testing
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],

      # Hex
      description: description(),
      package: package(),
      source_url: @url,
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:protobuf, "~> 0.10.0"},
      {:snappyer, "~> 1.2"},
      {:tesla, "~> 1.4"},
      {:hackney, "~> 1.17"},
      {:telemetry, "~> 1.0 or ~> 1.1"},
      # Testing
      {:bypass, "~> 2.1", only: :test},
      {:excoveralls, "~> 0.10", only: :test},
      # Formatting & Docs
      {:ex_doc, "~> 0.28", only: :dev, runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    """
    A client for sending logs to Grafana Loki.
    """
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @url},
      files: ~w(mix.exs lib README.md LICENSE.md),
      maintainers: ["Andreas Kasprzok"]
    ]
  end

  defp docs do
    [
      main: "Sleipnir",
      extras: ["README.md"]
    ]
  end

  defp preferred_cli_env do
    [
      {:test, :test}
    ]
  end
end
