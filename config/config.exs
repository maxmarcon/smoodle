# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :smoodle,
  ecto_repos: [Smoodle.Repo]

# Configures the endpoint
config :smoodle, SmoodleWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ynroQex1w7fNFgveammM2ftc9P4nvcOBJerr3w9leuhyI1/xajKt4Xi6da5afMeb",
  render_errors: [view: SmoodleWeb.ErrorView, accepts: ~w(html json), layout: {SmoodleWeb.LayoutView, "error.html"}],
  pubsub: [name: Smoodle.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :smoodle, SmoodleWeb.Plugs.Locale,
	use_session: true,
	available_locales: ~w(en de it)

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :template_engines,
    pug:  PhoenixExpug.Engine

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"


