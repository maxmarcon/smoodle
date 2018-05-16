defmodule Smoodle.Scheduler.Poll do
  use Ecto.Schema
  import Ecto.Changeset
  alias Smoodle.Scheduler.Poll


  schema "polls" do
    field :bad_dates, {:array, :string}
    field :good_dates, {:array, :string}
    field :weekdays_rank, {:map, :string}
    field :event_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Poll{} = poll, attrs) do
    poll
    |> cast(attrs, [:weekdays_rank, :bad_dates, :good_dates])
    |> validate_required([:weekdays_rank, :bad_dates, :good_dates])
  end
end
