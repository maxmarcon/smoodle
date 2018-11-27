defmodule Smoodle.Repo.Migrations.AddEventsPreferences do
  use Ecto.Migration

  def change do
  	alter table(:events) do
	  	add :preferences, :map
	  end
  end
end
