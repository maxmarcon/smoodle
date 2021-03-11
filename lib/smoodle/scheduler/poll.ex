defmodule Smoodle.Scheduler.Poll do
  use Ecto.Schema

  alias __MODULE__
  alias Smoodle.Scheduler.DateRank
  alias Smoodle.Scheduler.Event
  alias Smoodle.Scheduler.WeekDayRank

  require Protocol

  import Ecto.Changeset
  import SmoodleWeb.Gettext
  import Smoodle.Scheduler.Utils

  defimpl String.Chars, for: Smoodle.Scheduler.Poll do
    def to_string(poll) do
      "id:#{poll.id} participant:\"#{poll.participant}\" event_id:#{poll.event_id}"
    end
  end

  @primary_key {:id, :binary_id, autogenerate: true}

  @derive {Jason.Encoder, except: [:__meta__]}
  schema "polls" do
    field(:participant, :string)
    has_many(:date_ranks, DateRank, on_replace: :delete)

    embeds_one :preferences, Preferences, primary_key: false, on_replace: :delete do
      embeds_many(:weekday_ranks, WeekDayRank)
    end

    Protocol.derive(Jason.Encoder, Poll.Preferences)

    belongs_to(:event, Event, type: :binary_id)

    timestamps(type: :utc_datetime, usec: false)
  end

  @doc false
  def changeset(changeset, attrs) do
    # removed to allow organizer to change event window without invalidating existing polls
    # |> validate_date_ranks_within_event_time_window
    changeset
    |> cast(attrs, [:participant, :event_id])
    |> validate_event_open
    |> validate_event_domain_not_empty
    |> validate_required([:participant])
    |> cast_assoc(:date_ranks)
    |> cast_embed(:preferences, with: &preferences_changeset/2)
    |> validate_no_overlapping_dates(:date_ranks)
    |> validate_length(:date_ranks, max: 100)
    |> assoc_constraint(:event)
    |> unique_constraint(:participant, name: :polls_event_id_participant_index)
    |> trim_text_changes([:participant])
  end

  defp validate_event_domain_not_empty(changeset) do
    if Enum.empty?(Event.domain(get_field(changeset, :event))) do
      add_error(
        changeset,
        :event,
        dgettext("errors", "the event has no valid dates"),
        validation: :event_domain_empty
      )
    else
      changeset
    end
  end

  defp validate_event_open(changeset) do
    if Event.is_open(get_field(changeset, :event)) do
      changeset
    else
      add_error(
        changeset,
        :event,
        dgettext("errors", "event is no longer open"),
        validation: :event_no_longer_open
      )
    end
  end

  # defp validate_date_ranks_within_event_time_window(changeset) do
  #  %Event{time_window_from: from, time_window_to: to} = get_field(changeset, :event)
  #
  #  if changeset
  #     |> get_field(:date_ranks)
  #     |> Enum.filter(&(!is_nil(&1.date_from) && !is_nil(&1.date_to)))
  #     |> Enum.flat_map(&[&1.date_from, &1.date_to])
  #     |> Enum.all?(fn date ->
  #       Enum.member?(Date.range(from, to), date)
  #     end) do
  #    changeset
  #  else
  #    add_error(
  #      changeset,
  #      :date_ranks,
  #      dgettext("errors", "dates cannot be outside of the event time window"),
  #      validation: :date_ranks_outside_of_event_window
  #    )
  #  end
  # end

  defp preferences_changeset(preferences, attrs) do
    preferences
    |> cast(attrs, [])
    |> cast_embed(:weekday_ranks)
    |> validate_no_weekday_duplicates(:weekday_ranks)
  end
end
