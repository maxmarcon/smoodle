defmodule SmoodleWeb.EventChannelTest do
  use SmoodleWeb.ChannelCase
  alias SmoodleWeb.UserSocket
  alias Smoodle.Scheduler
  alias Smoodle.Repo

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
    {:ok, poll} = Scheduler.create_poll(event, @poll_attrs)

    [socket: socket, event: event, poll: poll]
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

  describe "after joining a channel for a public participants event as non-owner" do
    setup %{socket: socket, event: event} do
      {:ok, event} = Scheduler.update_event(event, %{public_participants: true})

      {:ok, reply, _} = subscribe_and_join(socket, "event:#{event.id}")

      [reply: reply, event: event]
    end

    test "the socket should reply with obfuscated event and unobfuscated schedule", %{
      reply: reply,
      event: event
    } do
      event = obfuscate_event(event)

      assert %{
               event: ^event,
               schedule: %{dates: _, participants: ["Betty Davies"], participants_count: 1}
             } = reply
    end

    test "should receive event_update events", %{event: event} do
      {:ok, event} = Scheduler.update_event(event, %{name: "Grill"})

      event = obfuscate_event(event)

      assert_push("event_update", %{
        event: ^event,
        schedule: %{dates: _, participants: ["Betty Davies"], participants_count: 1}
      })
    end

    test "should receive schedule_update events", %{poll: poll} do
      {:ok, _} = Scheduler.update_poll(Repo.reload(poll), %{participant: "Batman"})

      assert_push("schedule_update", %{
        schedule: %{dates: _, participants: ["Batman"], participants_count: 1}
      })
    end
  end

  describe "after joining a channel for a private-participants event as non-owner" do
    setup %{socket: socket, event: event} do
      {:ok, reply, _} = subscribe_and_join(socket, "event:#{event.id}")

      [reply: reply]
    end

    test "the socket should reply with obfuscated event and schedule", %{
      reply: reply,
      event: event
    } do
      event = obfuscate_event(event)

      assert %{event: ^event, schedule: %{dates: _, participants: [], participants_count: 1}} =
               reply
    end

    test "should receive event_update events", %{event: event} do
      {:ok, event} = Scheduler.update_event(event, %{name: "Grill"})

      event = obfuscate_event(event)
      assert_push("event_update", %{event: ^event})
    end

    test "should receive schedule_update events", %{poll: poll} do
      {:ok, _} = Scheduler.update_poll(poll, %{participant: "Batman"})

      assert_push("schedule_update", %{
        schedule: %{dates: _, participants: [], participants_count: 1}
      })
    end
  end

  describe "after joining a channel as event owner" do
    setup %{socket: socket, event: event} do
      assert {:ok, reply, _} =
               subscribe_and_join(socket, "event:#{event.id}", %{secret: event.secret})

      [reply: reply]
    end

    test "the socket should reply with unobfuscated event and schedule", %{
      reply: reply,
      event: event
    } do
      assert %{
               event: ^event,
               schedule: %{dates: _, participants: ["Betty Davies"], participants_count: 1}
             } = reply
    end

    test "should receive event_update events", %{event: event} do
      {:ok, _} = Scheduler.update_event(event, %{name: "Grill"})

      assert_push("event_update", %{event: %{name: "Grill"}})
    end

    test "should receive schedule_update events", %{poll: poll} do
      {:ok, _} = Scheduler.update_poll(poll, %{participant: "Batman"})

      assert_push("schedule_update", %{
        schedule: %{dates: _, participants: ["Batman"], participants_count: 1}
      })
    end
  end

  defp obfuscate_event(event) do
    %{event | email: nil, secret: nil}
  end
end
