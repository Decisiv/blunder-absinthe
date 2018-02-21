defmodule Blunder.Absinthe.Mixfile do
  use Mix.Project

  def project do
    [
      app: :blunder_absinthe,
      name: "Blunder.Absinthe",
      version: "0.1.2",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      source_url: repo_url(),
      docs: docs(),
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test, "ci": :test],
      dialyzer: [plt_add_deps: :transitive],
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
      {:bugsnag, "~> 1.3", optional: true},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:dataloader, "~> 1.0", optional: true},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false},
      {:ex_doc, "~> 0.18", only: :dev},
      {:excoveralls, "~> 0.8", only: :test},
      {:mock, "~> 0.3.0", only: :test},
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

  def aliases do
    [
      ci: [
        "coveralls --raise",
        "credo --strict",
      ]
    ]
  end

  defp description do
    """
    Package for simplifying error representation and handling in an Absinthe application
    """
  end

  defp repo_url, do: "https://github.decisiv.net/PlatformServices/blunder-absinthe"

end
