defmodule Smoodle.Scheduler.Event do
  use Ecto.Schema
  require Integer
  import Ecto.Changeset
  import SmoodleWeb.Gettext

  alias Smoodle.Repo
  alias Smoodle.Scheduler.Event
  alias Smoodle.Scheduler.Poll
  import Smoodle.Scheduler.Utils
  alias Smoodle.Scheduler.WeekdayConfig

  defimpl String.Chars, for: Smoodle.Scheduler.Event do
    def to_string(event) do
      "id:#{event.id} name:\"#{event.name}\" organizer:\"#{event.organizer}\" state:#{event.state}"
    end
  end

  @primary_key {:id, :binary_id, autogenerate: true}
  @secret_len 8
  @valid_states ["OPEN", "SCHEDULED", "CANCELED"]

  schema "events" do
    field(:name, :string)
    field(:organizer, :string)
    field(:secret, :string)
    field(:time_window_from, :date)
    field(:time_window_to, :date)
    field(:scheduled_from, :utc_datetime)
    field(:scheduled_to, :utc_datetime)
    field(:desc, :string)
    field(:organizer_message, :string)
    field(:email, :string)
    field(:state, :string, default: "OPEN")

    has_many(:polls, Poll)

    embeds_one(:preferences, Preferences, primary_key: false, on_replace: :delete) do
      embeds_many(:weekdays, WeekdayConfig)
    end

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
      :time_window_from,
      :time_window_to,
      :scheduled_from,
      :scheduled_to,
      :desc,
      :organizer_message,
      :email,
      :state
    ])
    |> validate_required([:name, :organizer, :email, :time_window_from, :time_window_to])
    |> validate_length(:name, max: 50)
    |> validate_length(:organizer, max: 50)
    |> validate_length(:desc, max: 250)
    |> validate_length(:organizer_message, max: 250)
    |> validate_format(:email, ~r/.+@.+\..+/)
    |> validate_length(:email, max: 100)
    |> validate_email_confirmation
    |> validate_window_defined([:scheduled_from, :scheduled_to], :scheduled)
    |> validate_window_consistent([:time_window_from, :time_window_to], :time_window, Date)
    |> validate_window_consistent([:scheduled_from, :scheduled_to], :scheduled)
    |> validate_is_the_future([:scheduled_from, :scheduled_to])
    |> validate_is_the_future([:time_window_from, :time_window_to], Date)
    |> validate_window_not_too_large([:time_window_from, :time_window_to], 365, :time_window)
    |> trim_text_changes([:name, :organizer, :desc])
    |> validate_inclusion(:state, @valid_states)
    |> clear_or_validate_scheduled
    |> clear_organizer_message
    |> cast_embed(:preferences, with: &preferences_changeset/2)
  end

  def changeset_insert(attrs) do
    changeset(%Event{}, attrs)
    |> change(%{secret: SecureRandom.urlsafe_base64(@secret_len)})
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

  defp validate_window_not_too_large(changeset, keys, max_days, error_key) do
    with [t1, t2] <- Enum.map(keys, &fetch_field(changeset, &1)) |> Enum.map(&elem(&1, 1)),
         false <- Enum.any?([t1, t2], &is_nil/1),
         true <- Date.diff(t2, t1) > max_days do
      add_error(
        changeset,
        error_key,
        dgettext(
          "errors",
          "you cannot select a time window larger than %{max_days} days",
          max_days: max_days
        ),
        validation: :time_interval_too_large
      )
    else
      _ -> changeset
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
        unless Enum.empty?(changes) ||
                 Enum.any?(changes, fn %{permitted: permitted} -> permitted end) do
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

  @doc """
    Using fetch_change and not fetch_field here because we still need to be able
    to update events whose time_window_from is in the past. Example: event has not been
    scheduled yet, but the current date already lies within the time window
  """
  defp validate_is_the_future(changeset, keys, t \\ DateTime) do
    today =
      case t do
        DateTime -> DateTime.utc_now()
        Date -> Date.utc_today()
      end

    Enum.reduce(keys, changeset, fn key, changeset ->
      with {:ok, date_or_time} <- fetch_change(changeset, key),
           %{} <- date_or_time,
           :gt <- t.compare(today, date_or_time) do
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
end
