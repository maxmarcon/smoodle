defmodule Smoodle.Mixfile do
  use Mix.Project

  def project do
    [
      app: :smoodle,
      version: "1.6.2",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Smoodle.Application, []},
      extra_applications: [:logger, :runtime_tools, :dotenv, :bamboo, :phoenix_ecto],
      included_applications: [:expug]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, "~> 0.11"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:plug, "~> 1.7"},
      {:plug_cowboy, "~> 2.0"},
      {:secure_random, "~> 0.5"},
      {:phoenix_expug, "~> 0.1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:dotenv, "~> 3.0.0"},
      {:bamboo, ">= 0.7.0"},
      {:bamboo_mailjet, "~> 0.1.0"},
      {:cachex, "~> 3.0"},
      {:distillery, "~> 2.0"},
      {:jason, "~> 1.1"},
      {:cors_plug, "~> 1.5"},
      {:junit_formatter, "~> 3.0", only: [:test]},
      {:faker, "~> 0.13", only: [:test, :dev]}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
