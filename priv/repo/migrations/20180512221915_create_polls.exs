defmodule Smoodle.Repo.Migrations.CreatePolls do
  use Ecto.Migration

  def change do
    create table(:polls) do
      add :participant, :string, null: false
      add :preferences, :json
      add :event_id, references(:events, on_delete: :delete_all, on_update: :update_all, type: :uuid), null: false

      timestamps()
    end

    #create unique_index(:polls, [:event_id, :participant])
  end
end
