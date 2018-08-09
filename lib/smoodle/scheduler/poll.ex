defmodule Smoodle.Scheduler.Poll do
  use Ecto.Schema
  import Ecto.Changeset
  alias Smoodle.Scheduler.Event
  alias Smoodle.Scheduler.Poll
  alias Smoodle.Scheduler.DateRank
  alias Smoodle.Scheduler.WeekDayRank
  import SmoodleWeb.Gettext
  import Smoodle.Scheduler.Utils

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "polls" do
    field :participant, :string
    has_many :date_ranks, DateRank, on_replace: :delete
    embeds_one :preferences, Preferences, primary_key: false, on_replace: :delete do
      embeds_many :weekday_ranks, WeekDayRank
    end
    belongs_to :event, Event, type: :binary_id

    timestamps(usec: false)
  end

  @doc false
  def changeset(changeset, attrs) do
    changeset
    |> cast(attrs, [:participant, :event_id])
    |> validate_event_open
    |> validate_required([:participant])
    |> cast_assoc(:date_ranks)
    |> cast_embed(:preferences, with: &preferences_changeset/2)
    |> validate_no_overlapping_date_ranks
    |> validate_date_ranks_within_event_time_window
    |> assoc_constraint(:event)
    |> unique_constraint(:participant, name: :polls_event_id_participant_index)
    |> trim_text_changes([:participant])
  end

  defp validate_event_open(changeset) do
    if Event.is_open(get_field(changeset, :event)) do
      changeset
    else
      add_error(changeset, :event, dgettext("errors", "event is no longer open"), validation: :event_no_longer_open)
    end
  end

  defp validate_date_ranks_within_event_time_window(changeset) do
    %Event{time_window_from: from, time_window_to: to} = get_field(changeset, :event)
    if changeset
      |> get_field(:date_ranks)
      |> Enum.filter(&(!is_nil(&1.date_from) && !is_nil(&1.date_to)))
      |> Enum.flat_map(&([&1.date_from, &1.date_to]))
      |> Enum.all?(fn date ->
        Enum.member?(Date.range(from, to), date)
      end) do
      changeset
    else
      add_error(changeset, :date_ranks, dgettext("errors", "dates cannot be outside of the event time_window"), validation: :date_ranks_outside_of_event_window)
    end
  end

  defp validate_no_overlapping_date_ranks(changeset) do
    flattened_ranks_sorted_by_date_from = changeset
    |> get_field(:date_ranks)
    |> Enum.filter(&(!is_nil(&1.date_from) && !is_nil(&1.date_to)))
    |> Enum.sort_by(&(&1.date_from), &date_lte/2)
    |> Enum.flat_map(&(Enum.uniq([&1.date_from, &1.date_to])))

    all_dates_sorted = Enum.sort(flattened_ranks_sorted_by_date_from, &date_lte/2)

    if flattened_ranks_sorted_by_date_from != all_dates_sorted || Enum.uniq(all_dates_sorted) != all_dates_sorted do
      add_error(changeset, :date_ranks, dgettext("errors", "dates cannot overlap"), validation: :overlapping_date_ranks)
    else
      changeset
    end
  end

  defp preferences_changeset(preferences, attrs) do
    preferences
    |> cast(attrs, [])
    |> cast_embed(:weekday_ranks)
    |> validate_no_weekday_duplicates
  end

  defp validate_no_weekday_duplicates(changeset) do
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
