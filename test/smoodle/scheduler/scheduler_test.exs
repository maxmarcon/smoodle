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
    time_window_from: "2117-03-01",
    time_window_to: "2117-06-01",
    email: "bot1@fake.com"
  }
  @event_valid_attrs_2 %{
    name: "Breakfast",
    desc: "Mmmhhh!",
    organizer: "The Hoff",
    time_window_from: "2118-01-01",
    time_window_to: "2118-06-01",
    email: "bot2@fake.com"
  }

  @event_update_attrs %{
    name: "New name",
    scheduled_from: "2117-03-20 20:10:00",
    scheduled_to: "2117-03-20 23:10:00",
    state: "SCHEDULED"
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
      events = Repo.preload(Scheduler.list_events(), :polls)
      assert MapSet.new(events) == MapSet.new(context[:events])
    end

    test "get_event!/1 returns the event with given id", context do
      [event1 | _] = context[:events]
      event = Repo.preload(Scheduler.get_event!(event1.id), :polls)
      assert event == event1
    end

    test "get_event!/2 returns the event with given id and secret", context do
      [event1 | _] = context[:events]
      event = Repo.preload(Scheduler.get_event!(event1.id, event1.secret), :polls)
      assert event == event1
    end

    test "get_event!/2 does not returns the event if the secret is wrong", context do
      [event1 | _] = context[:events]
      assert_raise(Ecto.NoResultsError, fn -> Scheduler.get_event!(event1.id, "wrong token") end)
    end
  end

  describe "when creating an event" do

    test "create_event/2 with valid data creates an event" do
      assert {:ok, %Event{} = event} = Scheduler.create_event(@event_valid_attrs_1)
      assert Map.take(event, [:name, :desc]) == Map.take(@event_valid_attrs_1, [:name, :desc])
      assert String.length(event.secret) == 32
      assert event.state == "OPEN"
      assert Repo.preload(Scheduler.get_event!(event.id), :polls) == event
    end

    #test "create_event/2 with valid data for validation does not create an event and returns valid changeset" do
    #  assert %{valid?: true} = Scheduler.create_event(@event_valid_attrs_1, dry_run: true)
    #  assert Scheduler.list_events() == []
    #end

    test "create_event/2 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scheduler.create_event(@event_invalid_attrs)
    end

    #test "create_event/2 with invalid data for validation returns invalid changeset" do
    #  assert %Ecto.Changeset{valid?: false} = Scheduler.create_event(@event_invalid_attrs, dry_run: true)
    #end
  end

  describe "when updating events" do

    setup do
      {:ok, event} = Scheduler.create_event(@event_valid_attrs_1)
      {:ok, scheduled_event} = Scheduler.create_event(Map.merge(@event_valid_attrs_1,
        %{
          scheduled_from: "2117-03-20 20:10:00",
          scheduled_to: "2117-03-20 23:10:00",
          state: "SCHEDULED"
        })
      )

      %{event: event, scheduled_event: scheduled_event}
    end

    test "update_event/2 with valid data updates the event", context do
      assert {:ok, event} = Scheduler.update_event(context[:event], @event_update_attrs)
      assert event.name == @event_update_attrs.name
      assert event.state == "SCHEDULED"
    end

    test "update_event/2 with valid data cannot update the token", context do
      event = context[:event]
      old_token = event.secret
      assert {:ok, event} = Scheduler.update_event(event, Map.merge(@event_update_attrs, %{secret: "sneaky_token"}))
      assert event.name == @event_update_attrs.name
      assert event.secret == old_token
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
    participant: "Betty Davies",
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
    }
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
          day: 4,
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
      %{event: event, polls: Enum.map([poll1, poll2], &(Map.delete(&1, :event)))}
    end

    test "get_poll!/1 fetches a poll", context do
      [poll1 | _] = context[:polls]
      poll = Map.delete(Scheduler.get_poll!(poll1.id), :event)
      assert poll == poll1
    end

    test "get_poll!/2 fetches a poll", context do
      [poll1 | _] = context[:polls]
      poll = Map.delete(Scheduler.get_poll!(poll1.event_id, poll1.participant), :event)
      assert poll == poll1
    end

    test "get_poll!/2 does not fetch a poll if the participant is wrong", context do
      [poll1 | _] = context[:polls]
      assert_raise(Ecto.NoResultsError, fn -> Scheduler.get_poll!(poll1.event_id, "wrong participant") end)
    end

    test "list_polls/1 fetches all polls for an event", context do
      polls = Enum.map(Scheduler.list_polls(context[:event]), &(Map.delete(&1, :event)))
      assert MapSet.new(polls) == MapSet.new(context[:polls])
    end
  end

  describe "when creating a poll" do

    setup do
      {:ok, event} = Scheduler.create_event(@event_valid_attrs_1)
      {:ok, poll} = Scheduler.create_poll(event, %{participant: "John Wayne"})
      %{event: event, poll: poll}
    end

    test "create_poll/3 valid data", context do
      assert {:ok, poll = %Poll{}} = Scheduler.create_poll(context[:event], @poll_valid_attrs_1)
      assert @poll_valid_attrs_1 = poll
      assert poll.event_id == context[:event].id
    end

    #test "create_poll/3 valid data for dry run does not create poll and returns valid changeset", context do
    #  assert changeset = Scheduler.create_poll(context[:event], @poll_valid_attrs_1, dry_run: true)
    #  assert changeset.valid?
    #  assert 1 = Repo.one(from p in Poll, select: count(p.id))
    #end

    test "create_poll/3 with invalid data returns changeset with errors", context do
      assert {:error, changeset} = Scheduler.create_poll(context[:event], Map.delete(@poll_valid_attrs_2, :participant))
      assert %{participant: [{_, validation: :required}]} = traverse_errors(changeset, &(&1))
    end

    #test "create_poll/3 with invalid data for dry run returns changeset with errors", context do
    #  changeset = Scheduler.create_poll(context[:event], Map.delete(@poll_valid_attrs_2, :participant), dry_run: true)
    #  refute changeset.valid?
    #  assert %{participant: [{_, validation: :required}]} = traverse_errors(changeset, &(&1))
    #end

    test "create_poll/3 with weekday ranks", context do
      assert {:ok, poll = %Poll{}} = Scheduler.create_poll(context[:event], @poll_valid_attrs_2)
      assert @poll_valid_attrs_2 = poll
    end

    test "create_poll/3 poll with date ranks", context do
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

    test "create_poll/3 with the same event and participant as another one", context do
      assert {:error, changeset} = Scheduler.create_poll(
        context[:event],
        Map.replace!(@poll_valid_attrs_1, :participant, context[:poll].participant)
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

    test "update_poll/3 with basic information", context do
      assert {:ok, poll = %Poll{}} = Scheduler.update_poll(context[:poll], %{participant: "Mike"})
      assert %{participant: "Mike"} = poll
    end

    #test "update_poll/3 with invalid data for dry run does not update the poll and returns invalid changeset", context do
    #  changeset = Scheduler.update_poll(context[:poll], %{participant: 1}, dry_run: true)
    #  refute changeset.valid?
    #  assert %{participant: [{_, [type: :string, validation: :cast]}]} = traverse_errors(changeset, &(&1))
    #end

    test "update_poll/3 with weekday_ranks", context do
      assert {:ok, poll = %Poll{}} = Scheduler.update_poll(context[:poll],
        %{preferences: %{ weekday_ranks: @new_weekday_ranks } }
      )
      assert @new_weekday_ranks = poll.preferences.weekday_ranks
      assert Enum.count(@new_weekday_ranks) == Enum.count(poll.preferences.weekday_ranks)
    end

    #test "update_poll/3 valid data for dry run does not update the poll and returns valid changeset", context do
    #  changeset = Scheduler.update_poll(context[:poll], %{participant: "Mike"}, dry_run: true)
    #  assert changeset.valid?
    #  assert context[:poll].participant == Repo.get!(Poll, context[:poll].id).participant
    #end

    test "update_poll/3 with invalid data returns changeset with errors", context do
      assert {:error, changeset} = Scheduler.update_poll(context[:poll], %{participant: 1})
      refute changeset.valid?
      assert %{participant: [{_, [type: :string, validation: :cast]}]} = traverse_errors(changeset, &(&1))
    end

    #test "update_poll/3 with invalid data returns error changeset", context do
    #  changeset = Scheduler.update_poll(context[:poll], %{participant: 1}, dry_run: true)
    #  refute changeset.valid?
    #  assert %{participant: [{_, [type: :string, validation: :cast]}]} = traverse_errors(changeset, &(&1))
    #end

    test "update_poll/3 with date ranks", context do
      assert {:ok, poll = %Poll{}} = Scheduler.update_poll(context[:poll],
        %{date_ranks: @new_date_ranks}
      )
      assert @new_date_ranks = Enum.map(poll.date_ranks, fn dr_attr ->
        %{
          date_from: Date.to_string(dr_attr.date_from),
          date_to: Date.to_string(dr_attr.date_to),
          rank: dr_attr.rank
        }
      end)
      assert Enum.count(@new_date_ranks) == Repo.one(from p in DateRank, select: count(p.id))
    end
  end

  describe "when deleting a poll" do

    setup do
      {:ok, event} = Scheduler.create_event(@event_valid_attrs_1)
      {:ok, poll} = Scheduler.create_poll(event, @poll_valid_attrs_3)
      %{event: event, poll: poll}
    end

    test "delete_poll/3 works", context do
      {:ok, poll} = Scheduler.delete_poll(context[:poll])
      assert_raise Ecto.NoResultsError, fn -> Scheduler.get_poll!(poll.id) end
      assert 0 = Repo.one(from p in DateRank, select: count(p.id))
    end
  end

  describe "when computing the best schedule" do
    setup do
      {:ok, event} = Scheduler.create_event(@event_valid_attrs_1)
      {:ok, poll1} = Scheduler.create_poll(event, @poll_valid_attrs_1)
      {:ok, poll2} = Scheduler.create_poll(event, @poll_valid_attrs_2)
      {:ok, poll3} = Scheduler.create_poll(event, @poll_valid_attrs_3)
      %{event: event, polls: [poll2, poll3, poll1]}
    end

    test "get_best_schedule returns the best date at the head of the list", %{event: event, polls: polls} do
      best_schedule = Scheduler.get_best_schedule(event)
      assert %{
        participants: participants,
        dates: dates
      } = best_schedule
      assert participants == Enum.count(polls)
      [best_date | _] = dates
      assert %{date: ~D[2117-03-15], positive_rank: 2.0} = best_date # It's a Monday :-)
    end

    test "get_best_schedule returns one entry for each date in the event window", %{event: event} do
      best_schedule = Scheduler.get_best_schedule(event)
      assert Enum.map(Date.range(event.time_window_from, event.time_window_to), &(&1)) |> Enum.sort ==
        Enum.map(best_schedule.dates, fn %{date: date} -> date end) |> Enum.sort
    end

    test "get_best_schedule called from non-owner does not include participant names", %{event: event} do
      best_schedule = Scheduler.get_best_schedule(event)
      assert Enum.all?(best_schedule.dates, &(!Map.has_key?(&1, :negative_participants)))
      assert Enum.all?(best_schedule.dates, &(!Map.has_key?(&1, :positive_participants)))
      assert is_integer(best_schedule.participants)
    end

    test "get_best_schedule called from owner does include participant names", %{event: event, polls: polls} do
      best_schedule = Scheduler.get_best_schedule(event, is_owner: true)
      assert Enum.any?(best_schedule.dates, &(Enum.any?(&1.negative_participants)))
      assert Enum.any?(best_schedule.dates, &(Enum.any?(&1.positive_participants)))
      assert Enum.sort(best_schedule.participants) == Enum.map(polls, &(Map.get(&1, :participant))) |> Enum.sort
    end

    test "get_best_schedule for event returns empty list when time window is invalid", %{event: event} do
      best_schedule = Scheduler.get_best_schedule(%{event | time_window_to: event.time_window_from, time_window_from: event.time_window_to}, is_owner: true)
      assert Enum.empty? best_schedule.dates
    end

     test "get_best_schedule returns a shorten list when a limit is passed", %{event: event} do
      best_schedule = Scheduler.get_best_schedule(event, limit: 1)
      assert Enum.count(best_schedule.dates) == 1
    end
  end

  describe "when computing the best schedule with no polls" do
    setup do
      {:ok, event} = Scheduler.create_event(@event_valid_attrs_1)
      %{event: event}
    end

    test "get_best_schedule returns an empty list", %{event: event} do
      best_schedule = Scheduler.get_best_schedule(event)
      assert best_schedule.participants == 0
      assert Enum.empty? best_schedule.dates
    end
  end
end
