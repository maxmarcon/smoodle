import Config

config :smoodle, SmoodleWeb.Endpoint,
  url: [
    host: System.get_env("HOST_NAME"),
    scheme: System.get_env("SCHEME", "https"),
    port: System.get_env("PORT", "443")
  ],
  secret_key_base: System.get_env("SECRET_KEY_BASE}")

config :smoodle, Smoodle.Repo, url: System.get_env("DATABASE_URL")

config :smoodle, Smoodle.Mailer,
  api_key: System.get_env("MAILJET_API_KEY"),
  api_private_key: System.get_env("MAILJET_API_PRIVATE_KEY")
