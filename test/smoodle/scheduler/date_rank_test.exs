defmodule Smoodle.Scheduler.DateRankTest do
  use Smoodle.DataCase
	alias Smoodle.Scheduler.DateRank

 # @event_attrs %{
#		name: "Party",
#		desc: "Yeah!",
#		organizer: "Donald Trump",
#		time_window_from: "2118-01-10",
#		time_window_to: "2118-03-20",
#		scheduled_from: "2118-02-05 19:00:00",
#		scheduled_to: "2118-02-05 23:00:00"
#	}
#
#	@poll_attrs %{
#		participant: "Betty Davies",
#		event_id: Ecto.UUID.generate()
#	}

  @valid_attrs %{
  	date_from: "2017-02-01",
  	date_to: "2017-03-24",
  	rank: 0.2,
		poll_id: Ecto.UUID.generate()
  }

  test "date rank is valid with valid data" do
  	changeset = DateRank.changeset(%DateRank{}, @valid_attrs)
  	assert changeset.valid?
  end

	test "date rank is invalid without a date" do
		changeset = DateRank.changeset(%DateRank{}, Map.delete(@valid_attrs, :date_from))
  	refute changeset.valid?
  	assert [date_from: {_, [validation: :required]}] = changeset.errors
  end

	test "date rank is invalid without rank" do
		changeset = DateRank.changeset(%DateRank{}, Map.delete(@valid_attrs, :rank))
  	refute changeset.valid?
  	assert [rank: {_, [validation: :required]}] = changeset.errors
  end

	test "date rank is invalid with a date_from later than date_to" do
		changeset = DateRank.changeset(%DateRank{}, Map.merge(
				@valid_attrs,
				%{
					date_from: @valid_attrs[:date_to],
					date_to: @valid_attrs[:date_from]
				}
			)
		)
  	refute changeset.valid?
  	assert [dates: {_, [validation: :inconsistent_interval]}] = changeset.errors
  end

	test "date rank is valid with date_from equal to date_to" do
		changeset = DateRank.changeset(%DateRank{}, Map.merge(
				@valid_attrs,
				%{
					date_from: @valid_attrs[:date_to],
					date_to: @valid_attrs[:date_to]
				}
			)
		)
  	assert changeset.valid?
  end
end