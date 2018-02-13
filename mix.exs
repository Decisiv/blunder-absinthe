defmodule Blunder.Absinthe.Mixfile do
  use Mix.Project

  def project do
    [
      app: :blunder_absinthe,
      name: "Blunder.Absinthe",
      version: "0.1.1",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      source_url: repo_url(),
      docs: docs(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Blunder.Absinthe.Application, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:absinthe, "~> 1.4"},
      {:blunder, "~> 1.0", organization: "decisiv"},
      {:bugsnag, "~> 1.3"},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false},
      {:ex_doc, "~> 0.18", only: :dev},
    ]
  end

  def docs do
    [
      main: "readme",
      source_url: repo_url(),
      extras: ["README.md"]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: [
        "Trevor Little"
      ],
      links: %{"Github" => repo_url()},
      organization: "decisiv",
    ]
  end

  defp description do
    """
    Package for simplifying error representation and handling in an Absinthe application
    """
  end

  defp repo_url, do: "https://github.decisiv.net/PlatformServices/blunder-absinthe"

end
