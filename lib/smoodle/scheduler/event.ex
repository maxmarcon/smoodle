defmodule Smoodle.Scheduler.Event do
  use Ecto.Schema
  require Integer
  import Ecto.Changeset
  import SmoodleWeb.Gettext

  alias Smoodle.Repo
  alias Smoodle.Scheduler.Event
  alias Smoodle.Scheduler.Poll
  import Smoodle.Scheduler.Utils

  @primary_key {:id, :binary_id, autogenerate: true}
  @secret_len 16

  schema "events" do
    field :name, :string
    field :organizer, :string
    field :secret, :string
    field :time_window_from, :date
    field :time_window_to, :date
    field :scheduled_from, :naive_datetime
    field :scheduled_to, :naive_datetime
    field :desc, :string
    field :email, :string
    has_many :polls, Poll

    timestamps(usec: false)
  end

  @doc false
  def changeset(%Event{} = event, attrs) do
    event
    |> Repo.preload(:polls)
    |> cast(attrs, [:name, :organizer, :time_window_from, :time_window_to, :scheduled_from, :scheduled_to, :desc, :email])
    |> validate_required([:name, :organizer, :desc, :email, :time_window_from, :time_window_to])
    |> validate_length(:name, max: 50)
    |> validate_length(:organizer, max: 50)
    |> validate_length(:desc, max: 250)
    |> validate_format(:email, ~r/.+@.+\..+/)
    |> validate_length(:email, max: 100)
    |> validate_window_defined([:scheduled_from, :scheduled_to], :scheduled)
    |> validate_window_consistent([:time_window_from, :time_window_to], :time_window, Date)
    |> validate_window_consistent([:scheduled_from, :scheduled_to], :scheduled)
    |> validate_is_the_future([:scheduled_from, :scheduled_to])
    |> validate_is_the_future([:time_window_from, :time_window_to], Date)
    |> validate_window_not_too_large([:time_window_from, :time_window_to], 365, :time_window)
    |> trim_text_changes([:name, :organizer, :desc])
  end

  def changeset_insert(attrs) do
    changeset(%Event{}, attrs) |>
    change(%{secret: SecureRandom.urlsafe_base64(@secret_len)})
  end

  defp validate_window_not_too_large(changeset, keys, max_days, error_key) do
    with [t1, t2] <- Enum.map(keys, &fetch_field(changeset, &1)) |> Enum.map(&elem(&1, 1)),
      false <- Enum.any?([t1, t2], &is_nil/1),
      true <- Date.diff(t2, t1) > max_days
    do
      add_error(changeset, error_key, dgettext("errors", "you cannot select a time window larger than %{max_days} days", max_days: max_days), validation: :time_interval_too_large)
    else
      _ -> changeset
    end
  end

  defp validate_window_defined(changeset, keys, error_key) do
    if Enum.map(keys, &fetch_field(changeset, &1))
      |> Enum.count(&is_nil(elem(&1, 1)))
      |> Integer.is_odd do
      add_error(changeset, error_key, dgettext("errors", "both ends must be defined or none"), validation: :only_one_end_defined)
    else
      changeset
    end
  end

  defp validate_is_the_future(changeset, keys, t \\ NaiveDateTime) do
    Enum.reduce(keys, changeset, fn(key, changeset) ->
      {_, date_or_time} = fetch_field(changeset, key)
      today = case t do
        NaiveDateTime -> NaiveDateTime.utc_now
        Date -> Date.utc_today
      end

      with %{} <- date_or_time,
        :gt <- t.compare(today, date_or_time)
      do
        add_error(changeset, key, dgettext("errors", "you cannot schedule an event in the past"), validation: :in_the_past)
      else
        _ -> changeset
      end
    end)
  end
end
