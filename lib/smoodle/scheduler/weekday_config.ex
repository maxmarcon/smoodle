defmodule Smoodle.Scheduler.WeekdayConfig do
  use Ecto.Schema
  alias Smoodle.Scheduler.WeekdayConfig
  import Ecto.Changeset
  import Smoodle.Scheduler.Utils

  @primary_key false

  embedded_schema do
    field(:day, :integer)
    field(:permitted, :boolean)
  end

  def changeset(%WeekdayConfig{} = weekday_permitted, attrs) do
    weekday_permitted
    |> cast(attrs, [:day, :permitted])
    |> validate_required([:day, :permitted])
    |> validate_number(:day, greater_than_or_equal_to: 0, less_than: 7)
  end
end
