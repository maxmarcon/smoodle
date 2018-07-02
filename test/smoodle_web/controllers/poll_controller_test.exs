defmodule SmoodleWeb.PollControllerTest do
  use SmoodleWeb.ConnCase

  alias Smoodle.Scheduler

	@event_attrs_1 %{
    name: "Party",
    desc: "Yeah!",
    organizer: "The Hoff",
    time_window_from: "2117-03-01",
    time_window_to: "2117-06-01"
  }

  @poll_valid_attrs_1 %{
    participant: "Michael Jordan",
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

  @poll_valid_attrs_2 %{
    participant: "Spike Lee",
    preferences: %{
      weekday_ranks: [
        %{
          day: 2,
          rank: -0.2
        },
        %{
          day: 4,
          rank: -1.0
        },
        %{
          day: 6,
          rank: 5.0
        }
      ]
    },
    date_ranks: [
      %{
        date_from: "2117-03-01",
        date_to: "2117-03-01",
        rank: -2.0
      },
      %{
        date_from: "2117-04-01",
        date_to: "2117-04-10",
        rank: +1.0
      }
    ]
  }

  def create_event(_) do
  	{:ok, event} = Scheduler.create_event(@event_attrs_1)
  	%{event: event}
  end

  def create_polls(context) do
  	{:ok, poll1} = Scheduler.create_poll(context[:event], @poll_valid_attrs_1)
  	{:ok, poll2} = Scheduler.create_poll(context[:event], @poll_valid_attrs_2)
  	%{polls: [poll1, poll2]}
  end

  def stringified_map struct, drops \\ [] do
  	Map.from_struct(struct)
  	|> Map.drop([:__meta__])
  	|> Enum.map(fn {k,v} ->
  		{Atom.to_string(k), v}
  	end)
  	|> Map.new
  end

  describe "index" do

  	setup [:create_event, :create_polls]

  	test "fetches all polls for event if owner token is passed", %{conn: conn, event: event, polls: polls} do
      conn = get conn, event_poll_path(conn, :index, event.id), %{owner_token: event.owner_token}
      assert length(json_response(conn, 200)["data"]) == 2
      data = json_response(conn, 200)["data"]
      assert MapSet.new(data) == MapSet.new(for poll <- polls, do: Map.drop(poll, [:event]))
  	end

  	test "does not fetch any polls for event if owner token is wrong", %{conn: conn, event: event, polls: polls} do
      assert_error_sent(:not_found, fn ->
      	get conn, event_poll_path(conn, :index, event.id), %{owner_token: "wrong token"}
      end)
  	end
  end

  describe "show" do

  	setup [:create_event, :create_polls]

  	test "fetches a poll via its id", %{conn: conn, polls: [poll | _]} do

  		conn = get conn, poll_path(conn, :show, poll.id)
  		data = json_response(conn, 200)["data"]
  		assert data["id"] == poll.id
  		assert data["event_id"] == poll.event_id
  		assert data["participant"] == poll.participant
  		assert 1 = SmoodleWeb.PollView.render("poll.json", %{poll: poll})
  	end
  end

end
