defmodule SmoodleWeb.EventChannelTest do
  use SmoodleWeb.ChannelCase
  alias SmoodleWeb.UserSocket
  alias Smoodle.Scheduler

  @event_attrs %{
    name: "Party",
    desc: "Yeah!",
    organizer: "The Hoff",
    possible_dates: [
      %{
        date_from: "2117-03-01",
        date_to: "2117-05-01",
        rank: 0
      },
      %{
        date_from: "2117-05-20",
        date_to: "2117-06-01",
        rank: 0
      }
    ],
    preferences: %{
      weekdays: [
        %{
          day: 0,
          rank: -1
        },
        %{
          day: 1,
          rank: -1
        },
        %{
          day: 2,
          rank: -1
        },
        %{
          day: 4,
          rank: -1
        }
      ]
    },
    email: "bot1@fake.com",
    email_confirmation: "bot1@fake.com",
    public_participants: false
  }

  @poll_attrs %{
    participant: "Betty Davies"
  }

  setup do
    socket = socket(UserSocket, "socket", %{})
    {:ok, event} = Scheduler.create_event(@event_attrs)
    {:ok, _} = Scheduler.create_poll(event, @poll_attrs)

    [socket: socket, event: event]
  end

  test "should be able to join a channel", %{socket: socket, event: event} do
    assert {:ok, _, _} = subscribe_and_join(socket, "event:#{event.id}")
  end

  test "should reject join for nonexistent event", %{socket: socket} do
    assert {:error, %{reason: "Event not found"}} ==
             subscribe_and_join(socket, "event:86211ba1-1f94-4a4f-b8bf-5e6eb4941eed")
  end

  test "should reject join for nonexistent event with invalid UUID", %{socket: socket} do
    assert {:error, %{reason: "Invalid event id"}} == subscribe_and_join(socket, "event:12")
  end

  describe "after having joined a channel as non-owner" do
    setup %{socket: socket, event: event} do
      assert {:ok, _, _} = subscribe_and_join(socket, "event:#{event.id}")

      :ok
    end

    test "should receive updates on the event", %{event: event} do
      {:ok, _} = Scheduler.update_event(event, %{name: "Grill"})

      assert_push("event_updated", %{event: %{name: "Grill"}})
    end

    test "should receive masked updates on the event's schedule", %{event: event} do
      {:ok, _} = Scheduler.update_event(event, %{name: "Grill"})

      assert_push("schedule_updated", %{
        schedule: %{dates: _, participants: [], participants_count: 1}
      })
    end
  end

  describe "after having joined a channel as event owner" do
    setup %{socket: socket, event: event} do
      assert {:ok, _, _} =
               subscribe_and_join(socket, "event:#{event.id}", %{secret: event.secret})

      :ok
    end

    test "should receive unmasked updates on the event's schedule", %{event: event} do
      {:ok, _} = Scheduler.update_event(event, %{name: "Grill"})

      assert_push("schedule_updated", %{
        schedule: %{dates: _, participants: [_], participants_count: 1}
      })
    end
  end
end
