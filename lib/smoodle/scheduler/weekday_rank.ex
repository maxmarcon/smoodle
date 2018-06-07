defmodule Smoodle.Scheduler.WeekDayRank do
	use Ecto.Schema
	alias Smoodle.Scheduler.WeekDayRank
  import Ecto.Changeset

  @primary_key false

	embedded_schema do
		field :day, :integer
		field :rank, :float
	end

	def changeset(%WeekDayRank{} = weekday_rank, attrs) do
		weekday_rank
		|> cast(attrs, [:day, :rank])
		|> validate_required([:day, :rank])
		|> validate_number(:rank, greater_than_or_equal_to: 0.0)
		|> validate_number(:day, greater_than_or_equal_to: 0, less_than: 7)
	end
end