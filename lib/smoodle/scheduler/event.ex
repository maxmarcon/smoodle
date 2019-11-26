defmodule Smoodle.Scheduler.Event do
  use Ecto.Schema

  alias __MODULE__
  alias Smoodle.Scheduler.Poll
  alias Smoodle.Scheduler.EventDate
  alias Smoodle.Scheduler.WeekdayConfig

  require Integer
  require Protocol

  import Ecto.Changeset
  import SmoodleWeb.Gettext
  import Smoodle.Scheduler.Utils

  defimpl String.Chars, for: Smoodle.Scheduler.Event do
    def to_string(event) do
      "id:#{event.id} name:\"#{event.name}\" organizer:\"#{event.organizer}\" state:#{event.state}"
    end
  end

  @primary_key {:id, :binary_id, autogenerate: true}
  @secret_len 8
  @valid_states ~W(OPEN SCHEDULED CANCELED)

  # Can't use "@derive Jason.Encoder" here becuase the field "secret" and "email"
  # must be encoded only sometimes, requiring conversion to a Map in event_view.ex

  schema "events" do
    field(:name, :string)
    field(:organizer, :string)
    field(:secret, :string)
    field(:scheduled_from, :utc_datetime)
    field(:scheduled_to, :utc_datetime)
    field(:desc, :string)
    field(:organizer_message, :string)
    field(:email, :string)
    field(:state, :string, default: "OPEN")
    field(:public_participants, :boolean, default: false)

    has_many(:polls, Poll)

    has_many(:possible_dates, EventDate, on_replace: :delete)

    embeds_one(:preferences, Preferences, primary_key: false, on_replace: :delete) do
      embeds_many(:weekdays, WeekdayConfig)
    end

    Protocol.derive(Jason.Encoder, Event.Preferences)

    timestamps(type: :utc_datetime, usec: false)
  end

  def is_open(%Event{} = event) do
    event.state == "OPEN"
  end

  @doc false
  def changeset(%Event{} = event, attrs) do
    event
    |> cast(attrs, [
      :name,
      :organizer,
      :scheduled_from,
      :scheduled_to,
      :desc,
      :organizer_message,
      :email,
      :state,
      :public_participants
    ])
    |> validate_required([:name, :organizer, :email])
    |> validate_length(:name, max: 50)
    |> validate_length(:organizer, max: 50)
    |> validate_length(:desc, max: 250)
    |> validate_length(:organizer_message, max: 250)
    |> validate_format(:email, ~r/.+@.+\..+/)
    |> validate_length(:email, max: 100)
    |> validate_email_confirmation
    |> cast_assoc(:possible_dates, required: true)
    |> validate_no_overlapping_dates(:possible_dates)
    |> validate_length(:possible_dates, max: 100)
    |> validate_window_defined([:scheduled_from, :scheduled_to], :scheduled)
    |> validate_window_consistent([:scheduled_from, :scheduled_to], :scheduled)
    |> validate_scheduled_in_the_future()
    |> trim_text_changes([:name, :organizer, :desc])
    |> validate_inclusion(:state, @valid_states)
    |> clear_or_validate_scheduled
    |> clear_organizer_message
    |> cast_embed(:preferences, with: &preferences_changeset/2)
    |> validate_domain_not_empty()
    |> validate_date_range_not_too_large(max_days: 365)
  end

  def changeset_insert(attrs) do
    changeset(%Event{}, attrs)
    |> change(%{secret: SecureRandom.urlsafe_base64(@secret_len)})
  end

  @doc """
  Returns the range of all the possible dates for this event

  iex> Event.date_range(%Event{preferences: nil, possible_dates: [%{date_from: ~D[2118-01-03], date_to: ~D[2118-01-05], rank: 0}, %{date_from: ~D[2118-01-07], date_to: ~D[2118-01-09], rank: 1}]})
  Date.range(~D[2118-01-03], ~D[2118-01-09])
  """
  def date_range(%Event{possible_dates: possible_dates}) do
    all_dates = Enum.flat_map(possible_dates, &Enum.uniq([&1.date_from, &1.date_to]))

    Date.range(
      Enum.min_by(all_dates, &Date.to_string/1),
      Enum.max_by(all_dates, &Date.to_string/1)
    )
  end

  @spec domain(%Event{preferences: map, possible_dates: list}) :: [Date.t()]
  @doc """

  iex> Event.domain(%Event{preferences: %{weekdays: []}, possible_dates: [%{date_from: ~D[2118-01-03], date_to: ~D[2118-01-09], rank: 0}]})
  [ ~D[2118-01-03], ~D[2118-01-04], ~D[2118-01-05], ~D[2118-01-06], ~D[2118-01-07], ~D[2118-01-08], ~D[2118-01-09] ]

  iex> Event.domain(%Event{preferences: nil, possible_dates: [%{date_from: ~D[2118-01-03], date_to: ~D[2118-01-09], rank: 0}]})
  [ ~D[2118-01-03], ~D[2118-01-04], ~D[2118-01-05], ~D[2118-01-06], ~D[2118-01-07], ~D[2118-01-08], ~D[2118-01-09] ]

  iex> Event.domain(%Event{preferences: nil, possible_dates: [%{date_from: ~D[2118-01-03], date_to: ~D[2118-01-05], rank: 0}, %{date_from: ~D[2118-01-07], date_to: ~D[2118-01-09], rank: 1}]})
  [ ~D[2118-01-03], ~D[2118-01-04], ~D[2118-01-05], ~D[2118-01-07], ~D[2118-01-08], ~D[2118-01-09] ]

  iex> Event.domain(%Event{preferences: %{weekdays: [%{day: 0, rank: -1}, %{day: 1, rank: -1}, %{day: 2, rank: -1}, %{day: 3, rank: -1}, %{day: 4, rank: -1}, %{day: 5, rank: -1}, %{day: 6, rank: -1}]}, possible_dates: [%{date_from: ~D[2118-01-03], date_to: ~D[2118-01-09], rank: 0}]})
  [ ]

  iex> Event.domain(%Event{preferences: %{weekdays: [%{day: 0, rank: -1}, %{day: 1, rank: -1}, %{day: 2, rank: -1}, %{day: 3, rank: -1}, %{day: 4, rank: -1}, %{day: 5, rank: -1}, %{day: 6, rank: -1}]}, possible_dates: [%{date_from: ~D[2118-01-03], date_to: ~D[2118-01-05], rank: 0}, %{date_from: ~D[2118-01-06], date_to: ~D[2118-01-07], rank: 1}]})
  [ ~D[2118-01-06], ~D[2118-01-07]]
  """
  def domain(%Event{
        preferences: preferences,
        possible_dates: possible_dates
      }) do
    # when there are no preferences or weekdays is empty, all days are good

    weekdays_ranks =
      if is_nil(preferences) do
        %{}
      else
        Map.new(preferences.weekdays, fn %{day: day, rank: rank} ->
          # convert from 0-based, Monday-first to 1-based Monday-first
          {day + 1, rank}
        end)
      end

    possible_dates
    |> Enum.flat_map(fn %{date_from: date_from, date_to: date_to, rank: rank} ->
      Enum.map(Date.range(date_from, date_to), &%{date: &1, rank: rank})
    end)
    |> Enum.reject(fn %{date: date} -> Date.compare(Date.utc_today(), date) == :gt end)
    |> Enum.reject(fn %{date: date, rank: rank} ->
      Map.get(weekdays_ranks, Date.day_of_week(date), 0) < 0 && rank <= 0
    end)
    |> Enum.map(fn %{date: date} -> date end)
  end

  defp clear_organizer_message(changeset) do
    {_, state} = fetch_field(changeset, :state)

    if state == "OPEN" do
      force_change(changeset, :organizer_message, nil)
    else
      changeset
    end
  end

  defp validate_email_confirmation(changeset) do
    with {:ok, _} <- fetch_change(changeset, :email) do
      validate_confirmation(changeset, :email, required: true)
    else
      _ -> changeset
    end
  end

  defp clear_or_validate_scheduled(changeset) do
    {_, state} = fetch_field(changeset, :state)

    if state != "SCHEDULED" do
      changeset
      |> force_change(:scheduled_from, nil)
      |> force_change(:scheduled_to, nil)
    else
      changeset
      |> validate_required(:scheduled_from)
      |> validate_required(:scheduled_to)
    end
  end

  defp validate_window_defined(changeset, keys, error_key) do
    if Enum.map(keys, &fetch_field(changeset, &1))
       |> Enum.count(&is_nil(elem(&1, 1)))
       |> Integer.is_odd() do
      add_error(
        changeset,
        error_key,
        dgettext("errors", "both ends must be defined or none"),
        validation: :only_one_end_defined
      )
    else
      changeset
    end
  end

  defp preferences_changeset(preferences, attrs) do
    preferences
    |> cast(attrs, [])
    |> cast_embed(:weekdays)
    |> validate_no_weekday_duplicates
    |> validate_one_weekday_enabled
  end

  defp validate_one_weekday_enabled(changeset) do
    case fetch_field(changeset, :weekdays) do
      {_, changes} ->
        if Enum.count(changes, fn %{rank: rank} -> rank < 0 end) == 7 do
          add_error(
            changeset,
            :weekdays,
            dgettext("errors", "enable at least one weekday."),
            validation: :no_weekdays_enabled
          )
        else
          changeset
        end

      _ ->
        changeset
    end
  end

  defp validate_scheduled_in_the_future(changeset) do
    Enum.reduce([:scheduled_from, :scheduled_to], changeset, fn key, changeset ->
      with {:ok, datetime} <- fetch_change(changeset, key),
           false <- is_nil(datetime),
           :gt <- DateTime.compare(DateTime.utc_now(), datetime) do
        add_error(
          changeset,
          key,
          dgettext("errors", "you cannot schedule an event in the past"),
          validation: :in_the_past
        )
      else
        _ -> changeset
      end
    end)
  end

  defp validate_domain_not_empty(changeset) do
    with true <- changeset.valid?,
         event <- Ecto.Changeset.apply_changes(changeset),
         true <- is_open(event),
         true <- Enum.empty?(domain(event)) do
      add_error(
        changeset,
        :possible_dates,
        dgettext("errors", "there must be at least one possible date"),
        validation: :empty
      )
    else
      _ -> changeset
    end
  end

  defp validate_date_range_not_too_large(changeset, max_days: max_days) do
    with true <- changeset.valid?,
         event <- Ecto.Changeset.apply_changes(changeset),
         date_range <- Event.date_range(event),
         false <- Enum.any?([date_range.first, date_range.last], &is_nil/1),
         true <- Date.diff(date_range.last, date_range.first) > max_days do
      add_error(
        changeset,
        :possible_dates,
        dgettext("errors", "you cannot select a time window larger than %{max_days} days",
          max_days: max_days
        ),
        validation: :time_interval_too_large
      )
    else
      _ -> changeset
    end
  end
end
