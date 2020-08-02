use Mix.Config

import_config "prod.exs"

config :smoodle, Smoodle.Mailer, adapter: Bamboo.LocalAdapter
