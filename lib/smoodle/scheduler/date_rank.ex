defmodule Smoodle.Scheduler.DateRank do
  use Ecto.Schema
  import Ecto.Changeset
  alias Smoodle.Scheduler.DateRank
  alias Smoodle.Scheduler.Poll
  import Smoodle.Scheduler.Utils

  schema "date_ranks" do
    field(:date_from, :date)
    field(:date_to, :date)
    field(:rank, :float)
    belongs_to(:poll, Poll, type: :binary_id)

    timestamps(type: :utc_datetime, usec: false)
  end

  def changeset(%DateRank{} = date_rank, attrs) do
    date_rank
    |> cast(attrs, [:date_from, :date_to, :rank, :poll_id])
    |> validate_required([:date_from, :date_to, :rank])
    |> validate_window_consistent([:date_from, :date_to], :dates, Date)
    |> validate_nonzero(:rank)
    |> assoc_constraint(:poll)
  end
end
