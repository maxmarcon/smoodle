use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :smoodle, SmoodleWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :smoodle, Smoodle.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "homestead",
  password: "secret",
  database: "smoodle_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :smoodle, Smoodle.Mailer,
  adapter: Bamboo.TestAdapter
