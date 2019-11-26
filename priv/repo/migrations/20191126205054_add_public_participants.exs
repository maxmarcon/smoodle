defmodule Smoodle.Repo.Migrations.AddPublicParticipants do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :public_participants, :boolean, null: false, default: false
    end
  end
end
