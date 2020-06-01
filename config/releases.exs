import Config

config :smoodle, SmoodleWeb.Endpoint,
       http: [port: System.get_env("PORT")],
       url: [host: System.get_env("HOST_NAME"), scheme: "http", port: System.get_env("PORT")],
       cache_static_manifest: "priv/static/cache_manifest.json",
       secret_key_base: System.get_env("SECRET_KEY_BASE}"),
       server: true

# Do not print debug messages in production
config :logger, level: :info

config :smoodle, Smoodle.Repo,
       url: System.get_env("DATABASE_URL"),
       database: "",
       ssl: false,
       pool_size: 2

