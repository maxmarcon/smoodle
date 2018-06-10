defmodule Smoodle.Scheduler.PollTest do

	use Smoodle.DataCase
	import Ecto.Changeset
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

	def build_weekday_ranks(_) do
		%{weekday_ranks: Enum.map(0..6, fn d -> %{day: d, rank: Enum.random([0, -0.2, -0.1, 0.1, 0.2])} end)}
	end

	def create_poll(context) do
		{:ok, poll} = Poll.changeset(%Poll{}, Map.merge(
			@poll_attrs,
			%{
				event_id: context[:event].id,
				preferences: %{
					weekday_ranks: context[:weekday_ranks]
				}
			}
		)) |> Repo.insert

		%{poll: poll}
	end

	def create_date_ranks(_) do
		%{date_ranks: [
				%{
					date_from: ~D[2118-01-12],
					date_to: ~D[2118-01-12],
					rank: -0.1
				},
				%{
					date_from: ~D[2118-01-15],
					date_to: ~D[2118-02-12],
					rank: +4.0
				},
				%{
					date_from: ~D[2118-02-20],
					date_to: ~D[2118-03-05],
					rank: -0.2
				}
			]
		}
	end


	test "poll cannot be inserted without a valid event id" do
		changeset = Poll.changeset(%Poll{}, @poll_attrs)
		assert {:error, changeset} = Repo.insert(changeset)
		assert [event: {"does not exist", _}] = changeset.errors
	end

	test "poll cannot be inserted without an event id" do
		changeset = Poll.changeset(%Poll{}, Map.delete(@poll_attrs, :event_id))
		refute changeset.valid?
		assert [event_id: {_, [validation: :required]}] = changeset.errors
	end

	test "poll cannot be inserted without a participant" do
		changeset = Poll.changeset(%Poll{}, Map.delete(@poll_attrs, :participant))
		assert {:error, changeset} = Repo.insert(changeset)
		assert [participant: {_, [validation: :required]}] = changeset.errors
	end

	describe "with invalid weekday_ranks" do

		setup :build_weekday_ranks

		test "poll cannot be inserted with invalid day", context do
			changeset = Poll.changeset(
				%Poll{},
				Map.merge(
					@poll_attrs,
					%{
						preferences: %{
							weekday_ranks: List.replace_at(context[:weekday_ranks], 0, %{day: 7, rank: 0.1})
						}
					}
				)
			)
			refute changeset.valid?
			assert %{preferences: %{weekday_ranks: [%{day: _} | _]}} = traverse_errors(changeset, &(&1))
		end

		test "poll cannot be inserted with invalid rank", context do
			changeset = Poll.changeset(
				%Poll{},
				Map.merge(
					@poll_attrs,
					%{
						preferences: %{
							weekday_ranks: List.replace_at(context[:weekday_ranks], 0, %{day: 0, rank: "bad"})
						}
					}
				)
			)
			refute changeset.valid?

			assert %{preferences: %{weekday_ranks: [%{rank: _} | _]}} = traverse_errors(changeset, &(&1))
		end

		test "poll cannot be inserted if a weekday is ranked more than once", context do
			changeset = Poll.changeset(
				%Poll{},
				Map.merge(
					@poll_attrs,
					%{
						preferences: %{
							weekday_ranks: [%{day: 0, rank: 0.5} | context[:weekday_ranks]]
						}
					}
				)
			)
			refute changeset.valid?

			assert %{preferences: %{weekday_ranks: [{_, [validation: :weekday_ranked_twice]}]}} = traverse_errors(changeset, &(&1))
		end

		test "poll cannot be inserted with bogus weekday ranks data" do
			changeset = Poll.changeset(
				%Poll{},
				Map.merge(
					@poll_attrs,
					%{
						preferences: %{
							weekday_ranks: [%{goo: 1, rank: 0.23}, %{day: 2, rank: 0.1}, "good", 123]
						}
					}
				)
			)
			refute changeset.valid?

			assert %{preferences: %{weekday_ranks: _}} = traverse_errors(changeset, &(&1))
		end
	end

	describe "with a valid event" do

		setup :create_event

		test "the poll can be inserted", context do
			changeset = Poll.changeset(%Poll{}, Map.put(@poll_attrs, :event_id, context[:event].id))
			assert {:ok, _} = Repo.insert(changeset)
		end
	end

	describe "with a valid event and weekdays_ranks" do

		setup [:create_event, :build_weekday_ranks]

		test "the poll can be inserted", context do
			changeset = Poll.changeset(
				%Poll{},
				Map.merge(
					@poll_attrs,
					%{
						event_id: context[:event].id,
						preferences: %{weekday_ranks: context[:weekday_ranks]}
					}
				)
			)
			assert {:ok, _} = Repo.insert(changeset)
		end
	end

	describe "with valid date ranks" do

		setup [:create_event, :create_date_ranks]

		test "the poll can be inserted", context do
			changeset = Poll.changeset(
				%Poll{},
				Map.merge(
					@poll_attrs,
					%{
						event_id: context[:event].id,
						date_ranks: context[:date_ranks]
					}
				)
			)
			assert {:ok, p} = Repo.insert(changeset)
		end
	end

	describe "with overlapping date ranks" do

		setup [:create_event, :create_date_ranks]

		test "the poll cannot be inserted", context do
			changeset = Poll.changeset(
				%Poll{},
				Map.merge(
					@poll_attrs,
					%{
						event_id: context[:event].id,
						date_ranks: [
							%{
								date_from: ~D[2118-01-31],
								date_to: ~D[2118-02-14],
								rank: +4.0
							}
							| context[:date_ranks]
						]
					}
				)
			)

			refute changeset.valid?
		end
	end

	describe "with date ranks outside of the event time window" do

		setup [:create_event, :create_date_ranks]

		test "the poll cannot be inserted", context do
			changeset = Poll.changeset(
				%Poll{},
				Map.merge(
					@poll_attrs,
					%{
						event_id: context[:event].id,
						date_ranks: [
							%{
								date_from: ~D[2118-03-10],
								date_to: ~D[2118-03-22],
								rank: +4.0
							}
							| context[:date_ranks]
						]
					}
				)
			)

			refute changeset.valid?
		end
	end

	describe "when updating a poll" do

		setup [:create_event, :build_weekday_ranks, :create_poll]

		test "weekday ranks get overwritten", context do

			new_weekday_ranks = [%{day: 0, rank: 0.1}, %{day: 6, rank: 0.2}]

			changeset = Poll.changeset(
				context[:poll],
				%{
					preferences: %{
						weekday_ranks: new_weekday_ranks
					}
				}
			)

			assert {:ok, new_poll} = Repo.update(changeset)
			assert Enum.map(new_poll.preferences.weekday_ranks, &Map.from_struct/1) == new_weekday_ranks
		end
	end
end