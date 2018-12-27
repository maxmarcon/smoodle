defmodule Smoodle.Repo.Migrations.DropTimeWindowFromEventsTable do
  use Ecto.Migration

  def change do
    alter table(:events) do
      remove(:time_window_from, :date)
      remove(:time_window_to, :date)
    end
  end
end
