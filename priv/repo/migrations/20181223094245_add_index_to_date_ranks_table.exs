defmodule Smoodle.Repo.Migrations.AddIndexToDateRanksTable do
  use Ecto.Migration

  def change do
    create(index(:date_ranks, [:date_from, :date_to, :poll_id], unique: true))
  end
end
