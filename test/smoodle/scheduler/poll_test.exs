defmodule Smoodle.Scheduler.PollTest do
  use ExUnit.Case
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
    scheduled_to: ~N[2118-02-05 23:00:00],
    email: "bot@fake.com"
  }

  @poll_attrs %{
    participant: "Betty Davies"
  }

  def build_basic_poll(_) do
    %{poll: %Poll{event: struct(Event, @event_attrs)}}
  end

  def build_weekday_ranks(_) do
    %{
      weekday_ranks:
        Enum.map(0..6, fn d -> %{day: d, rank: Enum.random([-0.2, -0.1, 0.1, 0.2])} end)
    }
  end

  def create_date_ranks(_) do
    %{
      date_ranks: [
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

  setup :build_basic_poll

  test "poll with basic data is valid", %{poll: poll} do
    changeset = Poll.changeset(poll, @poll_attrs)
    assert changeset.valid?
  end

  test "poll is invalid without a participant", %{poll: poll} do
    changeset = Poll.changeset(poll, Map.delete(@poll_attrs, :participant))
    refute changeset.valid?
    assert [participant: {_, [validation: :required]}] = changeset.errors
  end

  describe "with valid weekday_ranks" do
    setup :build_weekday_ranks

    test "poll is valid ", %{poll: poll, weekday_ranks: weekday_ranks} do
      changeset =
        Poll.changeset(
          poll,
          Map.merge(@poll_attrs, %{
            preferences: %{
              weekday_ranks: weekday_ranks
            }
          })
        )

      assert changeset.valid?
    end
  end

  describe "with invalid weekday_ranks" do
    setup :build_weekday_ranks

    test "poll is invalid with invalid day", %{poll: poll, weekday_ranks: weekday_ranks} do
      changeset =
        Poll.changeset(
          poll,
          Map.merge(@poll_attrs, %{
            preferences: %{
              weekday_ranks: List.replace_at(weekday_ranks, 0, %{day: 7, rank: 0.1})
            }
          })
        )

      refute changeset.valid?
      assert %{preferences: %{weekday_ranks: [%{day: _} | _]}} = traverse_errors(changeset, & &1)
    end

    test "poll is invalid with invalid rank", %{poll: poll, weekday_ranks: weekday_ranks} do
      changeset =
        Poll.changeset(
          poll,
          Map.merge(@poll_attrs, %{
            preferences: %{
              weekday_ranks: List.replace_at(weekday_ranks, 0, %{day: 0, rank: "bad"})
            }
          })
        )

      refute changeset.valid?

      assert %{preferences: %{weekday_ranks: [%{rank: _} | _]}} = traverse_errors(changeset, & &1)
    end

    test "poll is invalid with 0 weekday rank", %{poll: poll, weekday_ranks: weekday_ranks} do
      changeset =
        Poll.changeset(
          poll,
          Map.merge(@poll_attrs, %{
            preferences: %{
              weekday_ranks: List.replace_at(weekday_ranks, 0, %{day: 0, rank: 0.0})
            }
          })
        )

      refute changeset.valid?

      assert %{preferences: %{weekday_ranks: [%{rank: [{_, validation: :must_be_nonzero}]} | _]}} =
               traverse_errors(changeset, & &1)
    end

    test "poll is invalid if a weekday is ranked more than once", %{
      poll: poll,
      weekday_ranks: weekday_ranks
    } do
      changeset =
        Poll.changeset(
          poll,
          Map.merge(@poll_attrs, %{
            preferences: %{
              weekday_ranks: [%{day: 0, rank: 0.5} | weekday_ranks]
            }
          })
        )

      refute changeset.valid?

      assert %{preferences: %{weekday_ranks: [{_, [validation: :weekday_listed_twice]}]}} =
               traverse_errors(changeset, & &1)
    end

    test "poll is invalid with bogus weekday ranks data", %{poll: poll} do
      changeset =
        Poll.changeset(
          poll,
          Map.merge(@poll_attrs, %{
            preferences: %{
              weekday_ranks: [%{goo: 1, rank: 0.23}, %{day: 2, rank: 0.1}, "good", 123]
            }
          })
        )

      refute changeset.valid?

      assert %{preferences: %{weekday_ranks: _}} = traverse_errors(changeset, & &1)
    end
  end

  describe "with valid date ranks" do
    setup [:create_date_ranks]

    test "the poll is valid", %{poll: poll, date_ranks: date_ranks} do
      changeset =
        Poll.changeset(
          poll,
          Map.merge(@poll_attrs, %{
            date_ranks: date_ranks
          })
        )

      assert changeset.valid?
    end
  end

  describe "with overlapping date ranks" do
    setup [:create_date_ranks]

    test "the poll is invalid", %{poll: poll, date_ranks: date_ranks} do
      changeset =
        Poll.changeset(
          poll,
          Map.merge(@poll_attrs, %{
            date_ranks: [
              %{
                date_from: ~D[2118-03-05],
                date_to: ~D[2118-03-06],
                rank: +4.0
              }
              | date_ranks
            ]
          })
        )

      refute changeset.valid?

      assert %{date_ranks: [{_, [validation: :overlapping_dates]}]} =
               traverse_errors(changeset, & &1)
    end
  end

  describe "with more overlapping date ranks" do
    setup [:create_date_ranks]

    test "the poll is still invalid", %{poll: poll, date_ranks: date_ranks} do
      changeset =
        Poll.changeset(
          poll,
          Map.merge(@poll_attrs, %{
            date_ranks: [
              %{
                date_from: ~D[2118-01-13],
                date_to: ~D[2118-03-06],
                rank: +4.0
              }
              | date_ranks
            ]
          })
        )

      refute changeset.valid?

      assert %{date_ranks: [{_, [validation: :overlapping_dates]}]} =
               traverse_errors(changeset, & &1)
    end
  end

  describe "with bogus date ranks" do
    test "the poll is invalid", %{poll: poll} do
      changeset = Poll.changeset(poll, Map.merge(@poll_attrs, %{date_ranks: "foo"}))

      assert %{date_ranks: [{_, [validation: :assoc, type: {:array, :map}]}]} =
               traverse_errors(changeset, & &1)

      refute changeset.valid?
    end
  end

  describe "with date ranks outside of the event time window" do
    setup [:create_date_ranks]

    @tag :skip
    test "the poll is invalid", %{poll: poll, date_ranks: date_ranks} do
      changeset =
        change(poll)
        |> put_assoc(:event, struct(Event, @event_attrs))
        |> Poll.changeset(
          Map.merge(@poll_attrs, %{
            date_ranks: [
              %{
                date_from: ~D[2118-03-06],
                date_to: ~D[2118-03-21],
                rank: 1.0
              }
              | date_ranks
            ]
          })
        )

      refute changeset.valid?

      assert %{date_ranks: [{_, [validation: :date_ranks_outside_of_event_window]}]} =
               traverse_errors(changeset, & &1)
    end
  end

  describe "if the event is no longer open" do
    test "the poll is invalid", %{poll: poll} do
      poll = Map.update!(poll, :event, &Map.put(&1, :state, "CLOSED"))

      changeset =
        change(poll)
        |> Poll.changeset(@poll_attrs)

      refute changeset.valid?

      assert %{event: [{_, [validation: :event_no_longer_open]}]} =
               traverse_errors(changeset, & &1)
    end
  end

  describe "with date ranks inside the event time window" do
    setup [:create_date_ranks]

    test "the poll is valid", %{poll: poll, date_ranks: date_ranks} do
      changeset =
        change(poll)
        |> put_assoc(:event, struct(Event, @event_attrs))
        |> Poll.changeset(Map.merge(@poll_attrs, %{date_ranks: date_ranks}))

      assert changeset.valid?
    end
  end
end
