defmodule Smoodle.Scheduler.EventDate do
  use Ecto.Schema
  import Ecto.Changeset
  alias Smoodle.Scheduler.EventDate
  import Smoodle.Scheduler.Utils

  schema "event_dates" do
    field(:date_from, :date)
    field(:date_to, :date)
    belongs_to(:event, Event, type: :binary_id)

    timestamps(type: :utc_datetime, usec: false)
  end

  def changeset(%EventDate{} = event_date, attrs) do
    event_date
    |> cast(attrs, [:date_from, :date_to, :event_id])
    |> validate_required([:date_from, :date_to])
    |> validate_window_consistent([:date_from, :date_to], :dates, Date)
    |> assoc_constraint(:event)
  end
end
