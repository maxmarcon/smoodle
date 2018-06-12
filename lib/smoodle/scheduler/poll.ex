defmodule Smoodle.Scheduler.Poll do
  use Ecto.Schema
  import Ecto.Changeset
  alias Smoodle.Scheduler.Event
  alias Smoodle.Scheduler.Poll
  alias Smoodle.Scheduler.DateRank
  alias Smoodle.Scheduler.WeekDayRank
  import SmoodleWeb.Gettext
  alias Smoodle.Scheduler.Utils

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "polls" do
    field :participant, :string
    has_many :date_ranks, DateRank
    embeds_one :preferences, Preferences, primary_key: false, on_replace: :delete do
      embeds_many :weekday_ranks, WeekDayRank
    end
    belongs_to :event, Event

    timestamps()
  end

  @doc false
  def changeset(changeset, attrs) do
    changeset
    |> cast(attrs, [:participant, :event_id])
    |> validate_required([:participant])
    |> cast_assoc(:date_ranks)
    |> cast_embed(:preferences, with: &preferences_changeset/2)
    |> no_overlapping_date_ranks
    |> date_ranks_within_event_time_window
    |> assoc_constraint(:event)
  end

  defp date_ranks_within_event_time_window(changeset) do
    with %Event{} = event <- get_field(changeset, :event) do
      if changeset
        |> get_field(:date_ranks)
        |> Enum.flat_map(&([&1.date_from, &1.date_to]))
        |> Enum.all?(fn date ->
          Enum.member?(Date.range(event.time_window_from, event.time_window_to), date)
        end) do
        changeset
      else
        add_error(changeset, :date_ranks, dgettext("errors", "dates cannot be outside of the event time_window"), validation: :date_ranks_outside_of_event_window)
      end
    else
      _ -> changeset
    end
  end

  defp no_overlapping_date_ranks(changeset) do
    flattened_ranks_sorted_by_date_from = changeset
    |> get_field(:date_ranks)
    |> Enum.sort_by(&(&1.date_from), &Utils.<=/2)
    |> Enum.flat_map(&([&1.date_from, &1.date_to]))

    if flattened_ranks_sorted_by_date_from != Enum.sort(flattened_ranks_sorted_by_date_from, &Utils.<=/2) do
      add_error(changeset, :date_ranks, dgettext("errors", "dates cannot overlap"), validation: :overlapping_date_ranks)
    else
      changeset
    end
  end

  defp preferences_changeset(preferences, attrs) do
    preferences
    |> cast(attrs, [])
    |> cast_embed(:weekday_ranks)
    |> no_weekday_duplicates
  end

  defp no_weekday_duplicates(changeset) do
    case fetch_field(changeset, :weekday_ranks) do
      {_, changes} ->
        if Enum.count(Enum.uniq_by(changes, fn %{day: day} -> day end)) != Enum.count(changes) do
          add_error(changeset, :weekday_ranks, dgettext("errors", "you can only rank a weekday once"), validation: :weekday_ranked_twice)
        else
          changeset
        end
      _ -> changeset
    end
  end
end
