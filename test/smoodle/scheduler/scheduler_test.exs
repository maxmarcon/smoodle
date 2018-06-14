defmodule Smoodle.SchedulerTest do
  use Smoodle.DataCase
  alias Smoodle.Scheduler

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

  @poll_valid_attrs %{
    participant: "Betty Davies"
  }

  describe "events" do
    alias Smoodle.Scheduler.Event

    def event_fixture([_ | _] = attr_list) do
      Enum.map(attr_list, fn attrs ->
        {:ok, event} = Scheduler.create_event(attrs)

        event
      end)
    end

    def event_fixture(attrs) do
      {:ok, event} = Scheduler.create_event(attrs)

      event
    end

    test "list_events/0 returns all events" do
      events = event_fixture([@event_valid_attrs_1, @event_valid_attrs_2])
      assert MapSet.new(Repo.preload(Scheduler.list_events(), :polls)) == MapSet.new(events)
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture(@event_valid_attrs_1)
      assert Repo.preload(Scheduler.get_event!(event.id), :polls) == event
    end

    test "create_event/2 with valid data creates an event" do
      assert {:ok, %Event{} = event} = Scheduler.create_event(@event_valid_attrs_1)
      assert Map.take(event, [:name, :desc]) == Map.take(@event_valid_attrs_1, [:name, :desc])
      assert String.length(event.owner_token) == 32
      Scheduler.get_event!(event.id) == event
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

    test "update_event/2 with valid data updates the event" do
      event = event_fixture(@event_valid_attrs_1)
      assert {:ok, event} = Scheduler.update_event(event, @event_update_attrs)
      assert event.name == @event_update_attrs.name
    end

    test "update_event/2 with valid data cannot update the token" do
      event = event_fixture(@event_valid_attrs_1)
      old_token = event.owner_token
      assert {:ok, event} = Scheduler.update_event(event, Map.merge(@event_update_attrs, %{owner_token: "sneaky_token"}))
      assert event.name == @event_update_attrs.name
      assert event.owner_token == old_token
    end

    test "update_event/2 with valid data cannot update the id" do
      event = event_fixture(@event_valid_attrs_1)
      old_id = event.id
      assert {:ok, event} = Scheduler.update_event(event, Map.merge(@event_update_attrs, %{id: "sneaky_id"}))
      assert event.name == @event_update_attrs.name
      assert event.id == old_id
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture(@event_valid_attrs_1)
      assert {:error, %Ecto.Changeset{}} = Scheduler.update_event(event, @event_invalid_attrs)
      assert event == Repo.preload(Scheduler.get_event!(event.id), :polls)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture(@event_valid_attrs_1)
      assert {:ok, %Event{}} = Scheduler.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Scheduler.get_event!(event.id) end
    end
  end

  describe "polls" do
    alias Smoodle.Scheduler.Poll
    alias Smoodle.Scheduler.Event

    setup do
      {:ok, event} = Scheduler.create_event(@event_valid_attrs_1)
      [event: event]
    end

    test "can create a simple poll for an event", context do
      assert {:ok, poll = %Poll{}} = Scheduler.create_poll(context[:event], @poll_valid_attrs)
      assert @poll_valid_attrs = poll
      assert poll.event_id == context[:event].id
    end
  end
#
#    @event_valid_attrs %{bad_dates: [], good_dates: [], weekdays_rank: "some weekdays_rank"}
  #  @event_update_attrs %{bad_dates: [], good_dates: [], weekdays_rank: "some updated weekdays_rank"}
  #  @event_invalid_attrs %{bad_dates: nil, good_dates: nil, weekdays_rank: nil}
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
  #    assert poll.weekdays_rank == "some weekdays_rank"
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
  #    assert poll.weekdays_rank == "some updated weekdays_rank"
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
