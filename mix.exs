defmodule Sleipnir.MixProject do
  use Mix.Project

  @version "0.1.0"
  @url "https://github.com/akasprzok/sleipnir"

  def project do
    [
      app: :sleipnir,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

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
      {:ex_doc, "~> 0.28", only: :dev, runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:git_hooks, "~> 0.7", only: :dev, runtime: false},
      {:protobuf, "~> 0.10.0"},
      {:google_protos, "~> 0.1"},
      {:snappyer, "~> 1.2"}
    ]
  end

  defp description do
    """
    Sleipnir is a Loki client.
    """
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @url},
      maintainers: ["Andreas Kasprzok"]
    ]
  end

  defp docs do
    [
      main: "Deucalion",
      extras: ["README.md"]
    ]
  end
end
