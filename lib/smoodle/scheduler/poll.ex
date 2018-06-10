defmodule Smoodle.Scheduler.Poll do
  use Ecto.Schema
  import Ecto.Changeset
  alias Smoodle.Scheduler.Event
  alias Smoodle.Scheduler.Poll
  alias Smoodle.Scheduler.DateRank
  alias Smoodle.Scheduler.WeekDayRank
  import SmoodleWeb.Gettext

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
  def changeset(%Poll{} = poll, attrs) do
    poll
    |> cast(attrs, [:participant, :event_id])
    |> validate_required([:participant, :event_id])
    |> cast_assoc(:date_ranks)
    |> cast_embed(:preferences, with: &preferences_changeset/2)
#    |> no_overlapping_date_ranks
#    |> date_ranks_within_event_time_window
    |> assoc_constraint(:event)
  end

 #defp date_ranks_within_event_time_window(changeset) do
 #  Enum.reduce(fetch_field(:date_ranks), changeset, fn date_rank = %{date_from: dt, date_to: dt}, changeset ->
 #    if Date.compare(dt, )

 #  )
 #end

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
