defmodule Smoodle.Repo.Migrations.CreateDateRanks do
  use Ecto.Migration

  def change do
  	create table(:date_ranks) do
  		add :date_from, :date, null: false
  		add :date_to, :date, null: false
  		add :rank, :float, null: false
  		add :poll_id, references(:polls, on_delete: :delete_all, on_update: :update_all, type: :uuid), null: false

  		timestamps()
  	end
  end
end
