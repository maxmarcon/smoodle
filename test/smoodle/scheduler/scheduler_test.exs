defmodule Smoodle.SchedulerTest do
  use Smoodle.DataCase

  alias Smoodle.Scheduler

  describe "events" do
    alias Smoodle.Scheduler.Event

    @valid_attrs_1 %{
      name: "Party",
      desc: "Yeah!",
      time_window_from: "2017-03-01",
      time_window_to: "2017-06-01"
    }
    @valid_attrs_2 %{
      name: "Breakfast",
      desc: "Mmmhhh!",
      time_window_from: "2018-01-01",
      time_window_to: "2018-06-01"
    }
    
    @update_attrs %{
      name: "New name",
      scheduled_from: "2017-03-20 20:10:00",
      scheduled_to: "2017-03-20 23:10:00"
    }
    @invalid_attrs %{
      scheduled_to: "2017-03-20 20:10:00",
      scheduled_from: "2017-03-20 23:10:00"
    }

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
      events = event_fixture([@valid_attrs_1, @valid_attrs_2])
      assert MapSet.new(Scheduler.list_events()) == MapSet.new(events)
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture(@valid_attrs_1)
      assert Scheduler.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates an event" do
      assert {:ok, %Event{} = event} = Scheduler.create_event(@valid_attrs_1)
      assert Map.take(event, [:name, :desc]) == Map.take(@valid_attrs_1, [:name, :desc])
      assert String.length(event.update_token) == 32
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scheduler.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture(@valid_attrs_1)
      assert {:ok, event} = Scheduler.update_event(event, @update_attrs)
      assert event.name == @update_attrs.name
    end

    test "update_event/2 with valid data cannot update the token" do
      event = event_fixture(@valid_attrs_1)
      old_token = event.update_token
      assert {:ok, event} = Scheduler.update_event(event, Map.merge(@update_attrs, %{update_token: "sneaky_token"}))
      assert event.name == @update_attrs.name
      assert event.update_token == old_token
    end

    test "update_event/2 with valid data cannot update the id" do
      event = event_fixture(@valid_attrs_1)
      old_id = event.id
      assert {:ok, event} = Scheduler.update_event(event, Map.merge(@update_attrs, %{id: "sneaky_id"}))
      assert event.name == @update_attrs.name
      assert event.id == old_id
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture(@valid_attrs_1)
      assert {:error, %Ecto.Changeset{}} = Scheduler.update_event(event, @invalid_attrs)
      assert event == Scheduler.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture(@valid_attrs_1)
      assert {:ok, %Event{}} = Scheduler.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Scheduler.get_event!(event.id) end
    end
  end
end
