defmodule Smoodle.SchedulerTest do
  use Smoodle.DataCase
  alias Smoodle.Scheduler
  alias Smoodle.Scheduler.Event
  alias Smoodle.Scheduler.Poll
  alias Smoodle.Scheduler.DateRank

  import Ecto.Query

  @event_valid_attrs_1 %{
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

  @event_valid_attrs_2 %{
    name: "Breakfast",
    desc: "Mmmhhh!",
    organizer: "The Hoff",
    preferences: nil,
    possible_dates: [
      %{
        date_from: "2118-01-01",
        date_to: "2118-06-01",
        rank: 0
      }
    ],
    email: "bot2@fake.com",
    email_confirmation: "bot2@fake.com",
    public_participants: true
  }

  @event_update_attrs %{
    name: "New name",
    scheduled_from: "2117-03-20T20:10:00Z",
    scheduled_to: "2117-03-20T23:10:00Z",
    state: "SCHEDULED",
    public_participants: true
  }

  @event_invalid_attrs %{
    scheduled_to: "2117-03-20T20:10:00Z",
    scheduled_from: "2117-03-20T23:10:00Z"
  }

  defp check_new_event(data, event) do
    assert Map.take(data, [
             :organizer,
             :name,
             :desc,
             :email
           ]) ==
             Map.take(event, [
               :organizer,
               :name,
               :desc,
               :email
             ])

    assert is_nil(event.scheduled_from)
    assert is_nil(event.scheduled_to)

    assert data[:preferences] ==
             Map.update!(Map.from_struct(event.preferences), :weekdays, fn weekdays ->
               Enum.map(weekdays, &Map.from_struct/1)
             end)
  end

  describe "when retrieving events" do
    setup do
      {:ok, event1} = Scheduler.create_event(@event_valid_attrs_1)
      {:ok, event2} = Scheduler.create_event(@event_valid_attrs_2)

      %{events: [event1, event2]}
    end

    test "list_events/0 returns all events", %{events: events} do
      listed_events = Scheduler.list_events()
      assert MapSet.new(Repo.preload(listed_events, :possible_dates)) == MapSet.new(events)
    end

    test "get_event!/1 returns the event with given id", %{events: [event | _]} do
      fetched_event = Scheduler.get_event!(event.id)
      assert Repo.preload(fetched_event, :possible_dates) == event
    end

    test "get_event!/2 returns the event with given id, secret, mail and links", %{
      events: [event | _]
    } do
      fetched_event = Scheduler.get_event!(event.id, event.secret)
      assert Repo.preload(fetched_event, :possible_dates) == event
    end

    test "get_event!/2 does not returns the event if the secret is wrong", %{events: [event | _]} do
      assert_raise(Ecto.NoResultsError, fn -> Scheduler.get_event!(event.id, "wrong token") end)
    end
  end

  describe "when creating an event" do
    test "create_event/1 with valid data creates an event" do
      assert {:ok, %Event{} = event} = Scheduler.create_event(@event_valid_attrs_1)
      check_new_event(@event_valid_attrs_1, event)
      assert String.length(event.secret) == 16
      assert Map.has_key?(event, :inserted_at)
      assert event.state == "OPEN"
      assert Repo.preload(Scheduler.get_event!(event.id), :possible_dates) == event
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{valid?: false}} =
               Scheduler.create_event(@event_invalid_attrs)
    end

    test "create_event/2 with valid data for validation does not create an event" do
      assert :ok ==
               Scheduler.create_event(@event_valid_attrs_1, dry_run: true)

      assert Scheduler.list_events() == []
    end

    test "create_event/2 with invalid data for validation returns invalid changeset" do
      assert {:error, %Ecto.Changeset{valid?: false}} =
               Scheduler.create_event(@event_invalid_attrs, dry_run: true)
    end
  end

  describe "when updating events" do
    setup do
      {:ok, event} = Scheduler.create_event(@event_valid_attrs_1)

      {:ok, scheduled_event} =
        Scheduler.create_event(
          Map.merge(@event_valid_attrs_1, %{
            scheduled_from: "2117-03-20 20:10:00",
            scheduled_to: "2117-03-20 23:10:00",
            state: "SCHEDULED"
          })
        )

      %{event: event, scheduled_event: scheduled_event}
    end

    test "update_event/2 with valid data updates the event", %{event: event} do
      assert {:ok, updated_event} = Scheduler.update_event(event, @event_update_attrs)
      assert @event_update_attrs.name == updated_event.name
      assert @event_update_attrs.state == updated_event.state
      assert @event_update_attrs.public_participants == updated_event.public_participants

      {:ok, sfrom, _} = DateTime.from_iso8601(@event_update_attrs.scheduled_from)
      {:ok, sto, _} = DateTime.from_iso8601(@event_update_attrs.scheduled_to)
      assert sfrom == updated_event.scheduled_from
      assert sto == updated_event.scheduled_to
    end

    test "update_event/2 with valid data cannot update the token", %{event: event} do
      old_token = event.secret

      assert {:ok, updated_event} =
               Scheduler.update_event(
                 event,
                 Map.merge(@event_update_attrs, %{secret: "sneaky_token"})
               )

      assert updated_event.secret == old_token
    end

    test "update_event/2 with valid data cannot update the id", %{event: event} do
      old_id = event.id

      assert {:ok, updated_event} =
               Scheduler.update_event(event, Map.merge(@event_update_attrs, %{id: "sneaky_id"}))

      assert updated_event.id == old_id
    end

    test "update_event/2 with invalid data returns error changeset", context do
      event = context[:event]
      assert {:error, %Ecto.Changeset{}} = Scheduler.update_event(event, @event_invalid_attrs)
      assert event == Repo.preload(Scheduler.get_event!(event.id), :possible_dates)
    end

    test "update_event/3 with valid data for validation does not update an event", %{event: event} do
      assert :ok ==
               Scheduler.update_event(event, @event_update_attrs, dry_run: true)

      assert Repo.preload(Scheduler.get_event!(event.id), :possible_dates) == event
    end

    test "update_event/3 with invalid data for validation returns invalid changeset", %{
      event: event
    } do
      assert {:error, %Ecto.Changeset{valid?: false}} =
               Scheduler.update_event(event, @event_invalid_attrs, dry_run: true)
    end
  end

  describe "when deleting an event" do
    setup do
      {:ok, event1} = Scheduler.create_event(@event_valid_attrs_1)

      %{event: event1}
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
    participant: "Kim Novak",
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
        date_from: "2117-03-27",
        date_to: "2117-03-27",
        rank: +1.0
      }
    ]
  }

  @poll_valid_attrs_3 %{
    participant: "Michael Jordan",
    preferences: %{
      weekday_ranks: [
        %{
          day: 0,
          rank: 1.0
        },
        %{
          day: 5,
          rank: -1.0
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
        rank: -1.0
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

  @new_date_ranks [
    %{
      date_from: "2117-03-01",
      date_to: "2117-03-02",
      rank: +1.5
    },
    %{
      date_from: "2117-04-01",
      date_to: "2117-04-30",
      rank: -1.0
    }
  ]

  describe "when retrieving polls" do
    setup do
      {:ok, event} = Scheduler.create_event(@event_valid_attrs_1)
      {:ok, poll1} = Scheduler.create_poll(event, @poll_valid_attrs_1)
      {:ok, poll2} = Scheduler.create_poll(event, @poll_valid_attrs_2)
      %{event: event, polls: Enum.map([poll1, poll2], &Map.drop(&1, [:event, :date_ranks]))}
    end

    test "get_poll!/1 fetches a poll", %{polls: [poll | _]} do
      fetched_poll = Scheduler.get_poll!(poll.id)
      assert poll == Map.drop(fetched_poll, [:event, :date_ranks])
    end

    test "get_poll!/2 fetches a poll", %{polls: [poll | _]} do
      fetched_poll = Scheduler.get_poll!(poll.event_id, poll.participant)
      assert poll == Map.drop(fetched_poll, [:event, :date_ranks])
    end

    test "get_poll!/2 does not fetch a poll if the participant is wrong", %{polls: [poll | _]} do
      assert_raise(Ecto.NoResultsError, fn ->
        Scheduler.get_poll!(poll.event_id, "wrong participant")
      end)
    end

    test "list_polls/1 fetches all polls for an event", %{polls: polls, event: event} do
      fetched_polls = Enum.map(Scheduler.list_polls(event), &Map.drop(&1, [:event, :date_ranks]))
      assert MapSet.new(fetched_polls) == MapSet.new(polls)
    end
  end

  describe "when creating a poll" do
    setup do
      {:ok, event} = Scheduler.create_event(@event_valid_attrs_1)
      {:ok, poll} = Scheduler.create_poll(event, %{participant: "John Wayne"})
      %{event: event, poll: poll}
    end

    test "create_poll/3 valid data", %{event: event} do
      assert {:ok, poll = %Poll{}} = Scheduler.create_poll(event, @poll_valid_attrs_1)
      assert @poll_valid_attrs_1 = poll
      assert poll.event_id == event.id
    end

    test "create_poll/3 valid data for dry run does not create poll", %{event: event} do
      assert :ok == Scheduler.create_poll(event, @poll_valid_attrs_1, dry_run: true)
      assert 1 == Repo.one(from(p in Poll, select: count(p.id)))
    end

    test "create_poll/3 with invalid data returns changeset with errors", %{event: event} do
      assert {:error, changeset} =
               Scheduler.create_poll(
                 event,
                 Map.delete(@poll_valid_attrs_2, :participant)
               )

      assert [participant: {_, validation: :required}] = changeset.errors
    end

    test "create_poll/3 with invalid data for dry run returns changeset with errors", %{
      event: event
    } do
      assert {:error, changeset} =
               Scheduler.create_poll(event, Map.delete(@poll_valid_attrs_2, :participant),
                 dry_run: true
               )

      refute changeset.valid?
      assert %{participant: [{_, validation: :required}]} = traverse_errors(changeset, & &1)
    end

    test "create_poll/3 with weekday ranks", %{event: event} do
      poll_attrs = Map.delete(@poll_valid_attrs_2, :date_ranks)
      assert {:ok, poll = %Poll{}} = Scheduler.create_poll(event, poll_attrs)

      assert poll_attrs.preferences.weekday_ranks ==
               Enum.map(poll.preferences.weekday_ranks, &Map.from_struct/1)
    end

    test "create_poll/3 poll with date ranks", %{event: event} do
      assert {:ok, poll = %Poll{}} = Scheduler.create_poll(event, @poll_valid_attrs_3)

      expected_date_ranks =
        Enum.map(@poll_valid_attrs_3[:date_ranks], fn dr_attr ->
          %{
            date_from: dr_attr.date_from,
            date_to: dr_attr.date_to,
            rank: dr_attr.rank
          }
        end)

      assert ^expected_date_ranks =
               Enum.map(poll.date_ranks, fn dr_attr ->
                 %{
                   date_from: Date.to_string(dr_attr.date_from),
                   date_to: Date.to_string(dr_attr.date_to),
                   rank: dr_attr.rank
                 }
               end)
    end

    test "create_poll/3 with the same event and participant as another one", %{
      poll: poll,
      event: event
    } do
      assert {:error, changeset} =
               Scheduler.create_poll(
                 event,
                 Map.replace!(@poll_valid_attrs_1, :participant, poll.participant)
               )

      assert [
               participant:
                 {_, [constraint: :unique, constraint_name: "polls_event_id_participant_index"]}
             ] = changeset.errors
    end
  end

  describe "when updating a poll" do
    setup do
      {:ok, event} = Scheduler.create_event(@event_valid_attrs_1)
      {:ok, poll} = Scheduler.create_poll(event, @poll_valid_attrs_3)
      %{event: event, poll: poll}
    end

    test "update_poll/3 with basic information", %{poll: poll} do
      assert {:ok, updated_poll = %Poll{}} = Scheduler.update_poll(poll, %{participant: "Mike"})
      assert %{participant: "Mike"} = updated_poll
    end

    test "update_poll/3 with invalid data for dry run does not update the poll and returns invalid changeset",
         %{poll: poll} do
      assert {:error, changeset} = Scheduler.update_poll(poll, %{participant: 1}, dry_run: true)
      refute changeset.valid?

      assert %{participant: [{_, [type: :string, validation: :cast]}]} =
               traverse_errors(changeset, & &1)
    end

    test "update_poll/3 with weekday_ranks", %{poll: poll} do
      assert {:ok, poll = %Poll{}} =
               Scheduler.update_poll(poll, %{
                 preferences: %{weekday_ranks: @new_weekday_ranks}
               })

      assert @new_weekday_ranks = poll.preferences.weekday_ranks
      assert Enum.count(@new_weekday_ranks) == Enum.count(poll.preferences.weekday_ranks)
    end

    test "update_poll/3 valid data for dry run does not update the poll and returns valid changeset",
         %{poll: poll} do
      assert :ok == Scheduler.update_poll(poll, %{participant: "Mike"}, dry_run: true)
      assert poll.participant == Repo.get!(Poll, poll.id).participant
    end

    test "update_poll/3 with invalid data returns changeset with errors", %{poll: poll} do
      assert {:error, changeset} = Scheduler.update_poll(poll, %{participant: 1})
      refute changeset.valid?

      assert [participant: {_, [type: :string, validation: :cast]}] = changeset.errors
    end

    test "update_poll/3 with date ranks", %{poll: poll} do
      assert {:ok, poll = %Poll{}} = Scheduler.update_poll(poll, %{date_ranks: @new_date_ranks})

      assert @new_date_ranks =
               Enum.map(poll.date_ranks, fn dr_attr ->
                 %{
                   date_from: Date.to_string(dr_attr.date_from),
                   date_to: Date.to_string(dr_attr.date_to),
                   rank: dr_attr.rank
                 }
               end)

      assert Enum.count(@new_date_ranks) == Repo.one(from(p in DateRank, select: count(p.id)))
    end
  end

  describe "when deleting a poll" do
    setup do
      {:ok, event} = Scheduler.create_event(@event_valid_attrs_1)
      {:ok, poll} = Scheduler.create_poll(event, @poll_valid_attrs_3)
      %{event: event, poll: poll}
    end

    test "delete_poll/3 works", %{poll: poll} do
      {:ok, poll} = Scheduler.delete_poll(poll)
      assert_raise Ecto.NoResultsError, fn -> Scheduler.get_poll!(poll.id) end
      assert 0 = Repo.one(from(p in DateRank, select: count(p.id)))
    end
  end

  describe "when computing the best schedule" do
    setup do
      {:ok, event} = Scheduler.create_event(@event_valid_attrs_1)
      {:ok, poll1} = Scheduler.create_poll(event, @poll_valid_attrs_1)
      {:ok, poll2} = Scheduler.create_poll(event, @poll_valid_attrs_2)
      {:ok, poll3} = Scheduler.create_poll(event, @poll_valid_attrs_3)

      {:ok, public_participants_event} =
        Scheduler.create_event(%{@event_valid_attrs_1 | public_participants: true})

      {:ok, poll4} = Scheduler.create_poll(public_participants_event, @poll_valid_attrs_1)
      {:ok, poll5} = Scheduler.create_poll(public_participants_event, @poll_valid_attrs_2)
      {:ok, poll6} = Scheduler.create_poll(public_participants_event, @poll_valid_attrs_3)

      {:ok, true} = Cachex.del(Scheduler.schedule_cache(), event.id)

      %{
        event: event,
        polls: [poll2, poll3, poll1],
        public_participants_event: public_participants_event,
        public_polls: [poll4, poll5, poll6]
      }
    end

    test "get_best_schedule returns the best dates at the head of the list", %{event: event} do
      best_schedule = Scheduler.get_best_schedule(event)

      assert %{
               dates: dates
             } = best_schedule

      #      for d <- dates, do: IO.puts(inspect({Date.to_string(d.date), Date.day_of_week(d.date)-1, d.positive_rank, d.negative_rank}))

      [best1, best2, best3 | _] = dates

      # It's a Friday :-)
      assert %{date: ~D[2117-03-27], positive_rank: 2.0, negative_rank: 0} = best1
      assert %{date: ~D[2117-04-01], positive_rank: 1.0, negative_rank: 0} = best2
      assert %{date: ~D[2117-03-11], positive_rank: 0, negative_rank: 0} = best3
    end

    test "get_best_schedule honors the weekday preferences", %{event: event} do
      best_schedule = Scheduler.get_best_schedule(event)

      assert %{
               dates: dates
             } = best_schedule

      assert Enum.all?(dates, fn date ->
               Date.day_of_week(date.date) not in [1, 2, 3, 5]
             end)
    end

    test "get_best_schedule correctly computed the date domain for the event", %{event: event} do
      best_schedule = Scheduler.get_best_schedule(event)

      sorted_domain =
        Enum.flat_map(event.possible_dates, fn %{date_from: date_from, date_to: date_to} ->
          Date.range(date_from, date_to)
        end)
        |> Enum.filter(&(Date.day_of_week(&1) not in [1, 2, 3, 5]))
        |> Enum.sort(&(Date.compare(&1, &2) != :gt))

      computed_domain =
        Enum.map(best_schedule.dates, fn %{date: date} -> date end)
        |> Enum.sort(&(Date.compare(&1, &2) != :gt))

      assert sorted_domain == computed_domain
    end

    test "get_best_schedule returns the number of participants", %{event: event, polls: polls} do
      best_schedule = Scheduler.get_best_schedule(event)
      assert best_schedule.participants_count == Enum.count(polls)
    end

    test "get_best_schedule called from non-owner does not include participant names", %{
      event: event
    } do
      best_schedule = Scheduler.get_best_schedule(event)
      assert Enum.all?(best_schedule.dates, &(!Map.has_key?(&1, :negative_participants)))
      assert Enum.all?(best_schedule.dates, &(!Map.has_key?(&1, :positive_participants)))
      assert Enum.empty?(best_schedule.participants)
    end

    test "get_best_schedule called from owner does include participant names", %{
      event: event,
      polls: polls
    } do
      best_schedule = Scheduler.get_best_schedule(event, is_owner: true)
      assert Enum.any?(best_schedule.dates, &Enum.any?(&1.negative_participants))
      assert Enum.any?(best_schedule.dates, &Enum.any?(&1.positive_participants))

      assert Enum.sort(best_schedule.participants) ==
               Enum.map(polls, &Map.get(&1, :participant)) |> Enum.sort()
    end

    test "get_best_schedule called from non-owner does include participant names if participants are public",
         %{
           public_participants_event: public_participants_event,
           public_polls: polls
         } do
      best_schedule = Scheduler.get_best_schedule(public_participants_event)
      assert Enum.any?(best_schedule.dates, &Enum.any?(&1.negative_participants))
      assert Enum.any?(best_schedule.dates, &Enum.any?(&1.positive_participants))

      assert Enum.sort(best_schedule.participants) ==
               Enum.map(polls, &Map.get(&1, :participant)) |> Enum.sort()
    end

    test "get_best_schedule called from owner does include participant names if participants are public",
         %{
           public_participants_event: public_participants_event,
           public_polls: polls
         } do
      best_schedule = Scheduler.get_best_schedule(public_participants_event, is_owner: true)
      assert Enum.any?(best_schedule.dates, &Enum.any?(&1.negative_participants))
      assert Enum.any?(best_schedule.dates, &Enum.any?(&1.positive_participants))

      assert Enum.sort(best_schedule.participants) ==
               Enum.map(polls, &Map.get(&1, :participant)) |> Enum.sort()
    end

    test "get_best_schedule called from owner and then from non-owner does not include participant names",
         %{
           event: event,
           polls: polls
         } do
      best_schedule = Scheduler.get_best_schedule(event, is_owner: true)
      assert Enum.any?(best_schedule.dates, &Enum.any?(&1.negative_participants))
      assert Enum.any?(best_schedule.dates, &Enum.any?(&1.positive_participants))

      assert Enum.sort(best_schedule.participants) ==
               Enum.map(polls, &Map.get(&1, :participant)) |> Enum.sort()

      best_schedule = Scheduler.get_best_schedule(event)
      assert Enum.all?(best_schedule.dates, &(!Map.has_key?(&1, :negative_participants)))
      assert Enum.all?(best_schedule.dates, &(!Map.has_key?(&1, :positive_participants)))
      assert Enum.empty?(best_schedule.participants)
    end

    test "get_best_schedule returns a shortened list when a limit is passed", %{event: event} do
      best_schedule = Scheduler.get_best_schedule(event, limit: 1)
      assert Enum.count(best_schedule.dates) == 1
    end

    test "the result of get_best_schedule is cached", %{event: event} do
      assert {:ok, false} == Cachex.exists?(Scheduler.schedule_cache(), event.id)

      best_schedule = Scheduler.get_best_schedule(event, is_owner: true)

      assert {:ok, true} == Cachex.exists?(Scheduler.schedule_cache(), event.id)
      assert {:ok, best_schedule} == Cachex.get(Scheduler.schedule_cache(), event.id)
      {:ok, ttl} = Cachex.ttl(Scheduler.schedule_cache(), event.id)
      assert ttl <= Scheduler.ttl()
    end

    test "get_best_schedule returned cached results if these are present", %{event: event} do
      cached_schedule = %{dates: [], participants: [], participants_count: 10}
      Cachex.put(Scheduler.schedule_cache(), event.id, cached_schedule)

      assert cached_schedule == Scheduler.get_best_schedule(event)
    end
  end

  describe "when computing the best schedule with no polls" do
    setup do
      {:ok, event} = Scheduler.create_event(@event_valid_attrs_1)
      %{event: event}
    end

    test "get_best_schedule returns an empty list", %{event: event} do
      best_schedule = Scheduler.get_best_schedule(event)
      assert best_schedule.participants_count == 0
      assert Enum.empty?(best_schedule.dates)
    end
  end
end
