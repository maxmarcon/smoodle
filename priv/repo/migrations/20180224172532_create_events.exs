defmodule Smoodle.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
  	create table("events", primary_key: false) do
  		add :id, :uuid, primary_key: true
  		add :name, :string, null: false
  		add :time_window_from, :utc_datetime
  		add :time_window_to, :utc_datetime
  		add :scheduled_from, :utc_datetime
  		add :scheduled_to, :utc_datetime
  		add :desc, :text

  		timestamps()
  	end
  end
end
