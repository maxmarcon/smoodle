defmodule Smoodle.Scheduler.DateRankTest do
  use Smoodle.DataCase
	alias Smoodle.Scheduler.DateRank
	alias Smoodle.Scheduler.Poll
	alias Smoodle.Scheduler.Event

  @event_attrs %{
		name: "Party",
		desc: "Yeah!",
		organizer: "Donald Trump",
		time_window_from: "2118-01-10",
		time_window_to: "2118-03-20",
		scheduled_from: "2118-02-05 19:00:00",
		scheduled_to: "2118-02-05 23:00:00"
	}

	@poll_attrs %{
		participant: "Betty Davies",
		event_id: Ecto.UUID.generate()
	}

	def create_event(_) do
		{:ok, event} = Event.changeset_insert(@event_attrs) |> Repo.insert
		%{event: event}
	end

	def create_poll(context) do
		{:ok, poll} = Poll.changeset(%Poll{}, Map.merge(
			@poll_attrs,
			%{
				event_id: context[:event].id
			}
		)) |> Repo.insert

		%{poll: poll}
	end

  @valid_attrs %{
  	date_from: "2017-02-01",
  	date_to: "2017-03-24",
  	rank: 0.2,
		poll_id: Ecto.UUID.generate()
  }

  setup [:create_event, :create_poll]

  test "date rank can be inserted with valid data", context do
  	changeset = DateRank.changeset(%DateRank{}, Map.put(@valid_attrs, :poll_id, context[:poll].id))
  	assert changeset.valid?
  	assert {:ok, _} = Repo.insert(changeset)
  end

  test "date rank cannot be inserted without a valid poll id" do
  	changeset = DateRank.changeset(%DateRank{}, @valid_attrs)
  	assert {:error, changeset} = Repo.insert(changeset)
		assert [poll: {"does not exist", _}] = changeset.errors
  end

  test "date rank cannot be inserted without a poll id" do
  	changeset = DateRank.changeset(%DateRank{}, Map.delete(@valid_attrs, :poll_id))
  	assert_raise(Mariaex.Error, fn ->
  		Repo.insert(changeset)
  	end)
  end

	test "date rank cannot be inserted without a date" do
		changeset = DateRank.changeset(%DateRank{}, Map.delete(@valid_attrs, :date_from))
  	refute changeset.valid?
  	assert [date_from: {_, [validation: :required]}] = changeset.errors
  end

	test "date rank cannot be inserted without rank" do
		changeset = DateRank.changeset(%DateRank{}, Map.delete(@valid_attrs, :rank))
  	refute changeset.valid?
  	assert [rank: {_, [validation: :required]}] = changeset.errors
  end

	test "date rank cannot be inserted with a date_from later than date_to" do
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

	test "date rank can be inserted with date_from equal to date_to" do
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