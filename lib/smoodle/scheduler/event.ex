defmodule Smoodle.Scheduler.Event do
  use Ecto.Schema
  alias Smoodle.Scheduler.Event
  require Integer
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @update_token_len 16

  schema "events" do
    field :name, :string
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
    |> cast(attrs, [:name, :time_window_from, :time_window_to, :scheduled_from, :scheduled_to, :desc])
    |> validate_required([:name, :desc])
    |> validate_length(:name, max: 255)
    |> validate_length(:desc, max: 2500)
    |> validate_window_defined([:time_window_from, :time_window_to], :time_window)
    |> validate_window_defined([:scheduled_from, :scheduled_to], :scheduled)
    |> validate_time_window_consistent([:time_window_from, :time_window_to], :time_window)
    |> validate_scheduled_window_consistent([:scheduled_from, :scheduled_to], :scheduled)

    # TODO: validate scheduled window lies inside time window
  end

  def changeset_insert(attrs) do
    changeset(%Event{}, attrs) |>
    change(%{update_token: SecureRandom.urlsafe_base64(@update_token_len)})
  end

  defp validate_window_defined(changeset, keys, error_key) do
    if apply_changes(changeset)
      |> Map.take(keys)
      |> Map.values
      |> Enum.count(&(is_nil(&1)))
      |> Integer.is_odd
    do
      add_error(changeset, error_key, "both ends must be defined or none", [validation: :only_one_end_defined])
    else
      changeset
    end
  end

  defp validate_time_window_consistent(changeset, keys, error_key) do
    with applied <- apply_changes(changeset) |> Map.take(keys) |> Map.values,
      true <- Enum.all?(applied, &(!is_nil(&1))),
      [t1, t2] <- applied,
      :gt <- Date.compare(t1, t2)
    do
      add_error(changeset, error_key, "the right side of the window must happen later than the left one", [validation: :inconsistent_interval])
    else
      _ -> changeset
    end
  end

  defp validate_scheduled_window_consistent(changeset, keys, error_key) do
    with applied <- apply_changes(changeset) |> Map.take(keys) |> Map.values,
      true <- Enum.all?(applied, &(!is_nil(&1))),
      [t1, t2] <- applied,
      :gt <- NaiveDateTime.compare(t1, t2)
    do
      add_error(changeset, error_key, "the right side of the window must happen later than the left one", [validation: :inconsistent_interval])
    else
      _ -> changeset
    end
  end
end
