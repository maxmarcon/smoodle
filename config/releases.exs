import Config

config :smoodle, SmoodleWeb.Endpoint,
  http: [port: 4000],
  url: [
    host: System.get_env("HOST_NAME"),
    scheme: System.get_env("SCHEME", "https"),
    port: System.get_env("PORT", "443")
  ],
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: System.get_env("SECRET_KEY_BASE}"),
  server: true

# Do not print debug messages in production
config :logger, level: :info

config :smoodle, Smoodle.Repo,
  url: System.get_env("DATABASE_URL"),
  ssl: false,
  pool_size: 2

if System.get_env("LOCAL_EMAILS") do
  config :smoodle, Smoodle.Mailer, adapter: Bamboo.LocalAdapter
else
  config :smoodle, Smoodle.Mailer,
    adapter: Bamboo.MailjetAdapter,
    api_key: System.get_env("MAILJET_API_KEY"),
    api_private_key: System.get_env("MAILJET_API_PRIVATE_KEY")
end
