defmodule Smoodle.Scheduler.EventDate do
  use Ecto.Schema

  alias Smoodle.Scheduler.Event
  alias __MODULE__

  import Ecto.Changeset
  import Smoodle.Scheduler.Utils

  @derive {Jason.Encoder, only: [:date_to, :date_from, :rank]}

  schema "event_dates" do
    field(:date_from, :date)
    field(:date_to, :date)
    field(:rank, :float)
    belongs_to(:event, Event, type: :binary_id)

    timestamps(type: :utc_datetime, usec: false)
  end

  def changeset(%EventDate{} = event_date, attrs) do
    event_date
    |> cast(attrs, [:date_from, :date_to, :rank, :event_id])
    |> validate_required([:date_from, :date_to, :rank])
    |> validate_number(:rank, greater_than_or_equal_to: 0)
    |> validate_window_consistent([:date_from, :date_to], :dates, Date)
    |> assoc_constraint(:event)
  end
end
