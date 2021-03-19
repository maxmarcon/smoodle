defmodule SmoodleWeb.EventChannelTest do
  use SmoodleWeb.ChannelCase
  alias SmoodleWeb.UserSocket
  alias Smoodle.Scheduler
  alias Smoodle.Repo
  alias SmoodleWeb.EventController
  alias SmoodleWeb.EventView

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

  @poll_attrs_list [
    %{
      participant: "Betty Davies"
    },
    %{
      participant: "Superman"
    }
  ]

  @event_update_attrs %{
    scheduled_from: ~U[2117-04-05 21:10:00Z],
    scheduled_to: ~U[2117-04-05 22:10:00Z],
    state: "SCHEDULED",
    public_participants: true
  }

  @participant_names for e <- @poll_attrs_list, do: e.participant

  setup do
    socket = socket(UserSocket, "socket", %{})
    {:ok, event} = Scheduler.create_event(@event_attrs)

    polls =
      Enum.map(
        @poll_attrs_list,
        fn attrs ->
          {:ok, poll} = Scheduler.create_poll(event, attrs)
          poll
        end
      )

    [socket: socket, event: event, polls: polls]
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

  for {owner, user_type} <- [{true, "owner"}, {false, "non-owner"}] do
    for {public_participants, event_type} <- [
          {true, "public participants"},
          {false, "private participants"}
        ] do
      @owner owner
      @public_participants public_participants

      describe "after joining a channel for a #{event_type} event as #{user_type}" do
        setup %{socket: socket, event: event} do
          {:ok, event} =
            Scheduler.update_event(event, %{public_participants: @public_participants})

          {:ok, join_reply, socket} =
            subscribe_and_join(
              socket,
              "event:#{event.id}",
              if @owner do
                %{secret: event.secret}
              else
                %{}
              end
            )

          [join_reply: join_reply, event: event, socket: socket]
        end

        test "the socket should reply with event and schedule", %{
          join_reply: join_reply,
          event: event
        } do
          participants =
            if @owner || @public_participants do
              @participant_names
            else
              []
            end

          event =
            if @owner do
              EventView.add_links(event)
            else
              obfuscate_event(event)
            end

          assert %{
                   event: ^event,
                   schedule: %{
                     dates: _,
                     participants: ^participants,
                     participants_count: 2
                   }
                 } = join_reply
        end

        test "the socket should receive event_update events", %{event: event} do
          {:ok, event} = Scheduler.update_event(event, %{name: "Grill"})

          participants =
            if @owner || @public_participants do
              @participant_names
            else
              []
            end

          event =
            if @owner do
              EventView.add_links(event)
            else
              obfuscate_event(event)
            end

          assert_push(
            "event_update",
            %{
              event: ^event,
              schedule: %{
                dates: _,
                participants: ^participants,
                participants_count: 2
              }
            }
          )
        end

        test "the socket should receive event_delete events", %{event: event} do
          {:ok, _} = Scheduler.delete_event(event)

          assert_push(
            "event_delete",
            %{}
          )
        end

        test "the socket should receive schedule_update events when poll is deleted", %{
          polls: [poll | _]
        } do
          {:ok, _} = Scheduler.delete_poll(Repo.reload!(poll))

          participants =
            if @owner || @public_participants do
              ["Superman"]
            else
              []
            end

          assert_push(
            "schedule_update",
            %{
              schedule: %{
                dates: _,
                participants: ^participants,
                participants_count: 1
              }
            }
          )
        end

        test "should receive schedule_update events when poll is created", %{event: event} do
          {:ok, _} = Scheduler.create_poll(event, %{participant: "Batman"})

          participants =
            if @owner || @public_participants do
              ["Batman" | @participant_names]
            else
              []
            end

          assert_push(
            "schedule_update",
            %{
              schedule: %{
                dates: _,
                participants: ^participants,
                participants_count: 3
              }
            }
          )
        end

        test "should receive schedule_update events when poll is updated", %{polls: [poll | _]} do
          {:ok, _} = Scheduler.update_poll(Repo.reload(poll), %{participant: "Batman"})

          participants =
            if @owner || @public_participants do
              ["Batman", "Superman"]
            else
              []
            end

          assert_push(
            "schedule_update",
            %{
              schedule: %{
                dates: _,
                participants: ^participants,
                participants_count: 2
              }
            }
          )
        end

        test "the socket #{
               if owner do
                 "should"
               else
                 "should not"
               end
             } be able to update the event",
             %{socket: socket, event: event} do
          ref = push(socket, "update_event", %{event: @event_update_attrs})

          if @owner do
            assert_reply(ref, :ok, %{event: @event_update_attrs})
          else
            assert_reply(ref, :error, %{reason: "Forbidden"})
            refute_push("event_update", _)
          end
        end

        if owner do
          test "the socket should receive changeset errors if the event update does not pass validation",
               %{socket: socket, event: event} do
            ref = push(socket, "update_event", %{event: Map.put(@event_update_attrs, :name, nil)})

            assert_reply(ref, :error, %{reason: "Invalid", errors: %{name: _}})
            refute_push("event_update", _)
          end
        end
      end
    end
  end

  defp obfuscate_event(event) do
    %{event | email: nil, secret: nil}
  end
end
