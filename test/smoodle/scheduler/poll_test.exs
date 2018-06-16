defmodule Smoodle.Scheduler.PollTest do

	use Smoodle.DataCase
	import Ecto.Changeset
	alias Smoodle.Scheduler.Poll
	alias Smoodle.Scheduler.Event

	@event_attrs %{
		name: "Party",
		desc: "Yeah!",
		organizer: "Donald Trump",
		time_window_from: ~D[2118-01-10],
		time_window_to: ~D[2118-03-20],
		scheduled_from: ~N[2118-02-05 19:00:00],
		scheduled_to: ~N[2118-02-05 23:00:00]
	}

	@poll_attrs %{
		participant: "Betty Davies"
	}

	def build_weekday_ranks(_) do
		%{weekday_ranks: Enum.map(0..6, fn d -> %{day: d, rank: Enum.random([0, -0.2, -0.1, 0.1, 0.2])} end)}
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

	test "poll with basic data is valid" do
		changeset = Poll.changeset(%Poll{}, @poll_attrs)
		assert changeset.valid?
	end

	test "poll is invalid without a participant" do
		changeset = Poll.changeset(%Poll{}, Map.delete(@poll_attrs, :participant))
		refute changeset.valid?
		assert [participant: {_, [validation: :required]}] = changeset.errors
	end

	describe "with valid weekday_ranks" do

		setup :build_weekday_ranks

		test "poll is valid ", context do
			changeset = Poll.changeset(
				%Poll{},
				Map.merge(
					@poll_attrs,
					%{
						preferences: %{
							weekday_ranks: context[:weekday_ranks]
						}
					}
				)
			)
			assert changeset.valid?
		end
	end

	describe "with invalid weekday_ranks" do

		setup :build_weekday_ranks

		test "poll is invalid with invalid day", context do
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

		test "poll is invalid with invalid rank", context do
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

		test "poll is invalid if a weekday is ranked more than once", context do
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

		test "poll is invalid with bogus weekday ranks data" do
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


	describe "with valid date ranks" do

		setup [:create_date_ranks]

		test "the poll is valid", context do
			changeset = Poll.changeset(
				%Poll{},
				Map.merge(
					@poll_attrs,
					%{
						date_ranks: context[:date_ranks]
					}
				)
			)
			assert changeset.valid?
		end
	end

	describe "with overlapping date ranks" do

		setup [:create_date_ranks]

		test "the poll is invalid", context do
			changeset = Poll.changeset(
				%Poll{},
				Map.merge(
					@poll_attrs,
					%{
						date_ranks: [
							%{
								date_from: ~D[2118-03-05],
								date_to: ~D[2118-03-06],
								rank: +4.0
							}
							| context[:date_ranks]
						]
					}
				)
			)

			refute changeset.valid?
			assert %{date_ranks: [{_, [validation: :overlapping_date_ranks]}]} = traverse_errors(changeset, &(&1))
		end
	end

	describe "with more overlapping date ranks" do

		setup [:create_date_ranks]

		test "the poll is still invalid", context do
			changeset = Poll.changeset(
				%Poll{},
				Map.merge(
					@poll_attrs,
					%{
						date_ranks: [
							%{
								date_from: ~D[2118-01-13],
								date_to: ~D[2118-03-06],
								rank: +4.0
							}
							| context[:date_ranks]
						]
					}
				)
			)

			refute changeset.valid?
			assert %{date_ranks: [{_, [validation: :overlapping_date_ranks]}]} = traverse_errors(changeset, &(&1))
		end
	end

	describe "with bogus date ranks" do

		test "the poll is invalid" do

			changeset = Poll.changeset(%Poll{}, Map.merge(@poll_attrs, %{date_ranks: "foo"}))

			assert %{date_ranks: [{_, [type: {:array, :map}]}]} = traverse_errors(changeset, &(&1))
			refute changeset.valid?
		end
	end

	describe "with date ranks outside of the event time window" do

		setup [:create_date_ranks]

		test "the poll is invalid", context do

			changeset = change(%Poll{})
			|> put_assoc(:event, struct(Event, @event_attrs))
			|> Poll.changeset(Map.merge(@poll_attrs,
				%{date_ranks: [
					%{
						date_from: ~D[2118-03-06],
						date_to: ~D[2118-03-21],
						rank: 1.0
					}
					| context[:date_ranks] ]
				}
			))

			refute changeset.valid?
			assert %{date_ranks: [{_, [validation: :date_ranks_outside_of_event_window]}]} = traverse_errors(changeset, &(&1))
		end
	end

	describe "with date ranks inside the event time window" do

		setup [:create_date_ranks]

		test "the poll is valid", context do

			changeset = change(%Poll{})
			|> put_assoc(:event, struct(Event, @event_attrs))
			|> Poll.changeset(Map.merge(@poll_attrs,
				%{date_ranks: context[:date_ranks] }
			))

			assert changeset.valid?
		end
	end
end