defmodule Smoodle.Repo.Migrations.CreateDateRanks do
  use Ecto.Migration

  def change do
  	create table(:date_ranks) do
  		add :from_date, :date, null: false
  		add :to_date, :date, null: false
  		add :rank, :float, null: false
  		add :poll_id, references(:polls, on_delete: :delete_all, on_update: :update_all, type: :uuid), null: false

  		timestamps()
  	end
  end
end
