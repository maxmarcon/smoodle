defmodule Smoodle.Repo.Migrations.AddOrganizerMessage do
  use Ecto.Migration

  def change do
  	alter table(:events) do
  		add :organizer_message, :string
  	end
  end
end
