defmodule Smoodle.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
  	create table("events", primary_key: false) do
  		add :id, :uuid, primary_key: true
  		add :name, :string, null: false
      add :organizer, :string, null: false
      add :secret, :string, null: false
  		add :time_window_from, :date, null: false
  		add :time_window_to, :date, null: false
  		add :scheduled_from, :naive_datetime
  		add :scheduled_to, :naive_datetime
  		add :desc, :text
      add :email, :string
      add :state, :string

  		timestamps()
  	end
  end
end
