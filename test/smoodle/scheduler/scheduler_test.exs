defmodule Smoodle.SchedulerTest do
  use Smoodle.DataCase
  alias Smoodle.Scheduler
  alias Smoodle.Scheduler.Event
  alias Smoodle.Scheduler.Poll

  @event_valid_attrs_1 %{
    name: "Party",
    desc: "Yeah!",
    organizer: "The Hoff",
    time_window_from: "2117-03-01",
    time_window_to: "2117-06-01"
  }
  @event_valid_attrs_2 %{
    name: "Breakfast",
    desc: "Mmmhhh!",
    organizer: "The Hoff",
    time_window_from: "2118-01-01",
    time_window_to: "2118-06-01"
  }

  @event_update_attrs %{
    name: "New name",
    scheduled_from: "2117-03-20 20:10:00",
    scheduled_to: "2117-03-20 23:10:00"
  }

  @event_invalid_attrs %{
    scheduled_to: "2117-03-20 20:10:00",
    scheduled_from: "2117-03-20 23:10:00"
  }

  describe "when retrieving events" do

    setup do
      {:ok, event1} = Scheduler.create_event(@event_valid_attrs_1)
      {:ok, event2} = Scheduler.create_event(@event_valid_attrs_2)

      %{events: [event1, event2]}
    end

    test "list_events/0 returns all events", context do
      assert MapSet.new(Repo.preload(Scheduler.list_events(), :polls)) == MapSet.new(context[:events])
    end

    test "get_event!/1 returns the event with given id", context do
      [event | _] = context[:events]
      assert Repo.preload(Scheduler.get_event!(event.id), :polls) == event
    end
  end

  describe "when creating an vent" do

    test "create_event/2 with valid data creates an event" do
      assert {:ok, %Event{} = event} = Scheduler.create_event(@event_valid_attrs_1)
      assert Map.take(event, [:name, :desc]) == Map.take(@event_valid_attrs_1, [:name, :desc])
      assert String.length(event.owner_token) == 32
      assert Repo.preload(Scheduler.get_event!(event.id), :polls) == event
    end

    test "create_event/2 with valid data for validation does not create an event and returns valid changeset" do
      assert %{valid?: true} = Scheduler.create_event(@event_valid_attrs_1, dry_run: true)
      assert Scheduler.list_events() == []
    end

    test "create_event/2 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scheduler.create_event(@event_invalid_attrs)
    end

    test "create_event/2 with invalid data for validation returns invalid changeset" do
      assert %Ecto.Changeset{valid?: false} = Scheduler.create_event(@event_invalid_attrs, dry_run: true)
    end
  end

  describe "when updating events" do

    setup do
      {:ok, event1} = Scheduler.create_event(@event_valid_attrs_1)

      %{event: event1}
    end

    test "update_event/2 with valid data updates the event", context do
      assert {:ok, event} = Scheduler.update_event(context[:event], @event_update_attrs)
      assert event.name == @event_update_attrs.name
    end

    test "update_event/2 with valid data cannot update the token", context do
      event = context[:event]
      old_token = event.owner_token
      assert {:ok, event} = Scheduler.update_event(event, Map.merge(@event_update_attrs, %{owner_token: "sneaky_token"}))
      assert event.name == @event_update_attrs.name
      assert event.owner_token == old_token
    end

    test "update_event/2 with valid data cannot update the id", context do
      event = context[:event]
      old_id = event.id
      assert {:ok, event} = Scheduler.update_event(event, Map.merge(@event_update_attrs, %{id: "sneaky_id"}))
      assert event.name == @event_update_attrs.name
      assert event.id == old_id
    end

    test "update_event/2 with invalid data returns error changeset", context do
      event = context[:event]
      assert {:error, %Ecto.Changeset{}} = Scheduler.update_event(event, @event_invalid_attrs)
      assert event == Repo.preload(Scheduler.get_event!(event.id), :polls)
    end

    test "delete_event/1 deletes the event", context do
      event = context[:event]
      assert {:ok, %Event{}} = Scheduler.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Scheduler.get_event!(event.id) end
    end
  end


  @poll_valid_attrs_1 %{
    participant: "Betty Davies"
  }

  @poll_valid_attrs_2 %{
    participant: "Betty Davies",
    preferences: %{
      weekday_ranks: [
        %{
          day: 0,
          rank: 1.0
        },
        %{
          day: 6,
          rank: -1.0
        }
      ]
    }
  }

  @poll_valid_attrs_3 %{
    participant: "Betty Davies",
    preferences: %{
      weekday_ranks: [
        %{
          day: 0,
          rank: 1.0
        },
        %{
          day: 6,
          rank: -1.0
        }
      ]
    },
    date_ranks: [
      %{
        date_from: "2117-03-01",
        date_to: "2117-03-10",
        rank: -1.0
      },
      %{
        date_from: "2117-03-26",
        date_to: "2117-04-02",
        rank: +1.0
      },
      %{
        date_from: "2117-04-05",
        date_to: "2117-04-05",
        rank: 0.0
      }
    ]
  }


  @new_weekday_ranks [
    %{
      day: 0,
      rank: -1.0
    },
    %{
      day: 2,
      rank: 2.0
    },
    %{
      day: 3,
      rank: 2.0
    }
  ]

  describe "when creating a poll" do

    setup do
      {:ok, event} = Scheduler.create_event(@event_valid_attrs_1)
      {:ok, poll} = Scheduler.create_poll(event, %{participant: "John Wayne"})
      %{event: event, poll: poll}
    end

    test "can create a simple poll for an event", context do
      assert {:ok, poll = %Poll{}} = Scheduler.create_poll(context[:event], @poll_valid_attrs_1)
      assert @poll_valid_attrs_1 = poll
      assert poll.event_id == context[:event].id
    end

    test "cannot create a poll for an event without id", context do
      assert_raise(Mariaex.Error, fn ->
        Scheduler.create_poll(Map.delete(context[:event], :id), @poll_valid_attrs_1)
      end)
    end

    test "cannot create 2 polls for the same event and participant", context do
      assert {:ok, poll = %Poll{}} = Scheduler.create_poll(context[:event], @poll_valid_attrs_1)
      assert {:error, changeset} = Scheduler.create_poll(context[:event], @poll_valid_attrs_1)
      assert %{participant: [{_, []}]} = traverse_errors(changeset, &(&1))
    end

    test "can create a poll with weekday ranks", context do
      assert {:ok, poll = %Poll{}} = Scheduler.create_poll(context[:event], @poll_valid_attrs_2)
      assert @poll_valid_attrs_2 = poll
    end

    test "can create a poll with date ranks", context do
      assert {:ok, poll = %Poll{}} = Scheduler.create_poll(context[:event], @poll_valid_attrs_3)
      expected_date_ranks = Enum.map(@poll_valid_attrs_3[:date_ranks], fn dr_attr ->
        %{
          date_from: dr_attr.date_from,
          date_to: dr_attr.date_to,
          rank: dr_attr.rank
        }
      end)
      assert ^expected_date_ranks = Enum.map(poll.date_ranks, fn dr_attr ->
        %{
          date_from: Date.to_string(dr_attr.date_from),
          date_to: Date.to_string(dr_attr.date_to),
          rank: dr_attr.rank
        }
      end)
    end

    test "cannot create a poll with the same event and participant as another one", context do
      assert {:error, changeset} = Scheduler.create_poll(
        context[:event],
        Map.replace(@poll_valid_attrs_1, :participant, context[:poll].participant)
      )
      assert %{participant: [{_, _}]} = traverse_errors(changeset, &(&1))
    end
  end

  describe "when updating a poll" do

    setup do
      {:ok, event} = Scheduler.create_event(@event_valid_attrs_1)
      {:ok, poll} = Scheduler.create_poll(event, @poll_valid_attrs_3)
      %{event: event, poll: poll}
    end

    test "can update the basic information", context do
      assert {:ok, poll = %Poll{}} = Scheduler.update_poll(context[:poll], %{participant: "Mike"})
      assert %{participant: "Mike"} = poll
    end

    test "can update the weekday_ranks", context do

      assert {:ok, poll = %Poll{}} = Scheduler.update_poll(context[:poll],
        %{preferences: %{ weekday_ranks: @new_weekday_ranks } }
      )
      assert @new_weekday_ranks = poll.preferences.weekday_ranks
    end
  end
#
#    @event_valid_attrs %{bad_dates: [], good_dates: [], weekday_ranks: "some weekday_ranks"}
  #  @event_update_attrs %{bad_dates: [], good_dates: [], weekday_ranks: "some updated weekday_ranks"}
  #  @event_invalid_attrs %{bad_dates: nil, good_dates: nil, weekday_ranks: nil}
#
  #  def poll_fixture(attrs \\ %{}) do
  #    {:ok, poll} =
  #      attrs
  #      |> Enum.into(@event_valid_attrs)
  #      |> Scheduler.create_poll()
#
  #    poll
  #  end
#
  #  test "list_polls/0 returns all polls" do
  #    poll = poll_fixture()
  #    assert Scheduler.list_polls() == [poll]
  #  end
#
  #  test "get_poll!/1 returns the poll with given id" do
  #    poll = poll_fixture()
  #    assert Scheduler.get_poll!(poll.id) == poll
  #  end
#
  #  test "create_poll/1 with valid data creates a poll" do
  #    assert {:ok, %Poll{} = poll} = Scheduler.create_poll(@event_valid_attrs)
  #    assert poll.bad_dates == []
  #    assert poll.good_dates == []
  #    assert poll.weekday_ranks == "some weekday_ranks"
  #  end
#
  #  test "create_poll/1 with invalid data returns error changeset" do
  #    assert {:error, %Ecto.Changeset{}} = Scheduler.create_poll(@event_invalid_attrs)
  #  end
#
  #  test "update_poll/2 with valid data updates the poll" do
  #    poll = poll_fixture()
  #    assert {:ok, poll} = Scheduler.update_poll(poll, @event_update_attrs)
  #    assert %Poll{} = poll
  #    assert poll.bad_dates == []
  #    assert poll.good_dates == []
  #    assert poll.weekday_ranks == "some updated weekday_ranks"
  #  end
#
  #  test "update_poll/2 with invalid data returns error changeset" do
  #    poll = poll_fixture()
  #    assert {:error, %Ecto.Changeset{}} = Scheduler.update_poll(poll, @event_invalid_attrs)
  #    assert poll == Scheduler.get_poll!(poll.id)
  #  end
#
  #  test "delete_poll/1 deletes the poll" do
  #    poll = poll_fixture()
  #    assert {:ok, %Poll{}} = Scheduler.delete_poll(poll)
  #    assert_raise Ecto.NoResultsError, fn -> Scheduler.get_poll!(poll.id) end
  #  end
#
  #  test "change_poll/1 returns a poll changeset" do
  #    poll = poll_fixture()
  #    assert %Ecto.Changeset{} = Scheduler.change_poll(poll)
  #  end
  #end
end
