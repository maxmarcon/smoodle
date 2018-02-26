defmodule Smoodle.SchedulerTest do
  use Smoodle.DataCase

  alias Smoodle.Scheduler

  describe "events" do
    alias Smoodle.Scheduler.Event

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def event_fixture(attrs \\ %{}) do
      {:ok, event} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Scheduler.create_event()

      event
    end

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Scheduler.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Scheduler.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      assert {:ok, %Event{} = event} = Scheduler.create_event(@valid_attrs)
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scheduler.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()
      assert {:ok, event} = Scheduler.update_event(event, @update_attrs)
      assert %Event{} = event
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Scheduler.update_event(event, @invalid_attrs)
      assert event == Scheduler.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Scheduler.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Scheduler.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Scheduler.change_event(event)
    end
  end
end
