defmodule Smoodle.Scheduler.WeekDayRank do
  use Ecto.Schema
  alias Smoodle.Scheduler.WeekDayRank
  import Ecto.Changeset
  import Smoodle.Scheduler.Utils

  @primary_key false

  @derive Jason.Encoder

  embedded_schema do
    field(:day, :integer)
    field(:rank, :float)
  end

  def changeset(%WeekDayRank{} = weekday_rank, attrs) do
    weekday_rank
    |> cast(attrs, [:day, :rank])
    |> validate_required([:day, :rank])
    |> validate_number(:day, greater_than_or_equal_to: 0, less_than: 7)
    |> validate_nonzero(:rank)
  end
end
