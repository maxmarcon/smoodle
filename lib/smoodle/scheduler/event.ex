defmodule Smoodle.Scheduler.Event do
  use Ecto.Schema
  alias Smoodle.Scheduler.Event
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
    |> cast(attrs, [:name, :time_window_from, :time_window_to, :desc])
    |> validate_required([:name, :desc])
    |> validate_length(:name, max: 255, count: :codepoints)
    |> validate_length(:desc, max: 2500, count: :codepoints)
  end
end
