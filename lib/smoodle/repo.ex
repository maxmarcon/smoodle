defmodule Smoodle.Repo do
  use Ecto.Repo,
    otp_app: :smoodle,
    adapter: Ecto.Adapters.Postgres
end
