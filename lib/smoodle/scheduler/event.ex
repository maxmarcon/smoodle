defmodule Smoodle.Scheduler.Event do
  use Ecto.Schema
  alias Smoodle.Scheduler.Event
  require Integer
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "events" do
    field :name, :string
    field :time_window_from, :utc_datetime
    field :time_window_to, :utc_datetime
    field :scheduled_from, :utc_datetime
    field :scheduled_to, :utc_datetime
    field :desc, :string

    timestamps()
  end

  @doc false
  def changeset_create(%Event{} = event, attrs) do
    event
    |> cast(attrs, [:name, :time_window_from, :time_window_to, :scheduled_from, :scheduled_to, :desc])
    |> validate_required([:name, :desc])
    |> validate_length(:name, max: 255, count: :codepoints)
    |> validate_length(:desc, max: 2500, count: :codepoints)
    |> validate_time_window_defined([:time_window_from, :time_window_to], :time_window)
    |> validate_time_window_defined([:scheduled_from, :scheduled_to], :scheduled)
    |> validate_time_window_consistent([:time_window_from, :time_window_to], :time_window)
    |> validate_time_window_consistent([:scheduled_from, :scheduled_to], :scheduled)
  end


  defp validate_time_window_defined(changeset, keys, error_key) do
    if apply_changes(changeset)
      |> Map.take(keys)
      |> Map.values
      |> Enum.count(&(is_nil(&1)))
      |> Integer.is_odd
    do
      add_error(changeset, error_key, "both ends must be defined or none")
    else
      changeset
    end
  end

  defp validate_time_window_consistent(changeset, keys, error_key) do
    if Enum.all?(applied = (apply_changes(changeset) |> Map.take(keys) |> Map.values), &(!is_nil(&1)))
      && Enum.reduce(applied, &(DateTime.diff(&1, &2))) <= 0
    do
      add_error(changeset, error_key, "the right side of the window must happen later than the left one")
    else
      changeset
    end
  end
end
