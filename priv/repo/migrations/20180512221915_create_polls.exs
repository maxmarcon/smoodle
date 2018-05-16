defmodule Smoodle.Repo.Migrations.CreatePolls do
  use Ecto.Migration

  def change do
    create table(:polls) do
      add :name, :string
      add :weekdays_rank, :json
      add :bad_dates, :json
      add :good_dates, :json
      add :event_id, references(:events, on_delete: :nothing, type: :uuid)

      timestamps()
    end
  end
end
