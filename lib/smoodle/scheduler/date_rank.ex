defmodule Smoodle.Scheduler.DateRank do
  use Ecto.Schema
  import Ecto.Changeset
  alias Smoodle.Scheduler.DateRank
  import Smoodle.Scheduler.Utils

  @foreign_key_type :binary_id

  schema "date_ranks" do
  	field :date_from, :date
  	field :date_to, :date
  	field :rank, :float
  	belongs_to :poll, Poll

    timestamps()
  end

  def changeset(%DateRank{} = date_rank, attrs) do
  	date_rank
  	|> cast(attrs, [:date_from, :date_to, :rank, :poll_id])
  	|> validate_required([:date_from, :date_to, :rank, :poll_id])
    |> validate_window_consistent([:date_from, :date_to], :dates, Date)
  	|> assoc_constraint(:poll)
  end
end