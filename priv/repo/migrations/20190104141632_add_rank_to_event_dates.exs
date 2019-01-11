defmodule Smoodle.Repo.Migrations.AddRankToEventDates do
  use Ecto.Migration

  def change do
    alter table(:event_dates) do
      add(:rank, :float, null: false, default: 0)
    end
  end
end
