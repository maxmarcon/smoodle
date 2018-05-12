defmodule Smoodle.Scheduler.Event do
  use Ecto.Schema
  alias Smoodle.Scheduler.Event
  require Integer
  import Ecto.Changeset
  import SmoodleWeb.Gettext

  @primary_key {:id, :binary_id, autogenerate: true}
  @update_token_len 16

  schema "events" do
    field :name, :string
    field :organizer, :string
    field :update_token, :string
    field :time_window_from, :date
    field :time_window_to, :date
    field :scheduled_from, :naive_datetime
    field :scheduled_to, :naive_datetime
    field :desc, :string

    timestamps(usec: false)
  end

  @doc false
  def changeset(%Event{} = event, attrs) do
    event
    |> cast(attrs, [:name, :organizer, :time_window_from, :time_window_to, :scheduled_from, :scheduled_to, :desc])
    |> validate_required([:name, :organizer, :desc, :time_window_from, :time_window_to])
    |> validate_length(:name, max: 50)
    |> validate_length(:organizer, max: 50)
    |> validate_length(:desc, max: 250)
    |> validate_window_defined([:scheduled_from, :scheduled_to], :scheduled)
    |> validate_window_consistent([:time_window_from, :time_window_to], :time_window, Date)
    |> validate_window_consistent([:scheduled_from, :scheduled_to], :scheduled)
    |> validate_is_the_future([:scheduled_from, :scheduled_to])
    |> validate_is_the_future([:time_window_from, :time_window_to], Date)
  end

  def changeset_insert(attrs) do
    changeset(%Event{}, attrs) |>
    change(%{update_token: SecureRandom.urlsafe_base64(@update_token_len)})
  end

  defp validate_window_defined(changeset, keys, error_key) do
    if Enum.map(keys, &fetch_field(changeset, &1))
      |> Enum.count(&is_nil(elem(&1, 1)))
      |> Integer.is_odd do
      add_error(changeset, error_key, dgettext("errors", "both ends must be defined or none"), [validation: :only_one_end_defined])
    else
      changeset
    end
  end

  defp validate_window_consistent(changeset, keys, error_key, t \\ NaiveDateTime) do
    with [t1, t2] <- Enum.map(keys, &fetch_field(changeset, &1))
      |> Enum.map(&elem(&1, 1)),
      false <- Enum.any?([t1, t2], &is_nil/1),
      :gt <- t.compare(t1, t2)
    do
      add_error(changeset, error_key, dgettext("errors", "the right side of the window must happen later than the left one"), [validation: :inconsistent_interval])
    else
      _ -> changeset
    end
  end

  defp validate_is_the_future(changeset, keys, t \\ NaiveDateTime)

  defp validate_is_the_future(changeset, [], _t) do
    changeset
  end

  defp validate_is_the_future(changeset, [key | tail], t) do
    {_, date_or_time} = fetch_field(changeset, key)
    today = case t do
      NaiveDateTime -> NaiveDateTime.utc_now
      Date -> Date.utc_today
    end

    changeset = with %{} <- date_or_time,
      :gt <- t.compare(today, date_or_time)
    do
      add_error(changeset, key, dgettext("errors", "you cannot schedule an event in the past"), [validation: :in_the_past])
    else
      _ -> changeset
    end

    validate_is_the_future(changeset, tail, t)
  end
end
