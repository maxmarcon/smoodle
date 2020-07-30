use Mix.Config

config :smoodle, SmoodleWeb.Endpoint,
  http: [port: 4000],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true

# Do not print debug messages in production
config :logger, level: :info

config :smoodle, Smoodle.Repo,
  ssl: false,
  pool_size: 2
