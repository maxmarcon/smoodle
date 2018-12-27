defmodule Smoodle.Repo.Migrations.AddEventDatesTable do
  use Ecto.Migration

  def change do
    create table(:event_dates) do
      add(:date_from, :date, null: false)
      add(:date_to, :date, null: false)

      add(
        :event_id,
        references(:events, on_delete: :delete_all, on_update: :update_all, type: :uuid),
        null: false
      )

      timestamps()
    end

    create(index(:event_dates, [:event_id, :date_from, :date_to], unique: true))
  end
end
