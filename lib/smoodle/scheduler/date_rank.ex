defmodule Smoodle.Scheduler.DateRank do
  use Ecto.Schema
  import Ecto.Changeset
  alias Smoodle.Scheduler.DateRank

  schema "date_ranks" do
  	field :date_from, :date
  	field :date_to, :date
  	field :rank, :float
  	belongs_to :poll, Poll
  end

  def changeset(%DateRank{} = date_rank, attrs) do
  	date_rank
  	|> cast(attrs, [:date_from, :date_to, :rank])
  	|> validate_required([:date_from, :date_to, :rank])
  	|> assoc_constraint(:poll)
  end
end