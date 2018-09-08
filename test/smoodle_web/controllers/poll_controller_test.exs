defmodule SmoodleWeb.PollControllerTest do
  use SmoodleWeb.ConnCase

  alias Smoodle.Scheduler

  @event_attrs_1 %{
    name: "Party",
    desc: "Yeah!",
    organizer: "The Hoff",
    time_window_from: "2117-03-01",
    time_window_to: "2117-06-01",
    email: "bot@fake.com",
    email_confirmation: "bot@fake.com"
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
        rank: -0.5
      }
    ]
  }

  @poll_update_attrs_1 %{
    preferences: %{
      weekday_ranks: [
        %{
          day: 3,
          rank: 1.0
        }
      ]
    },
    date_ranks: [
      %{
        date_from: "2117-03-01",
        date_to: "2117-03-01",
        rank: -1.2
      },
      %{
        date_from: "2117-04-05",
        date_to: "2117-04-10",
        rank: 1.0
      }
    ]
  }

  @poll_update_invalid_attrs_1 %{
    preferences: %{
      weekday_ranks: [
        %{
          day: 8,
          rank: 1.0
        }
      ]
    },
    date_ranks: [
      %{
        date_from: "2117-03-01",
        date_to: "2117-03-01",
        rank: -1.2
      },
      %{
        date_from: "2117-03-01",
        date_to: "2117-04-10",
        rank: 1.0
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

  @poll_invalid_attrs %{
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

  defp create_event(_) do
    {:ok, event} = Scheduler.create_event(@event_attrs_1)
    %{event: event}
  end

  defp create_polls(context) do
    {:ok, poll1} = Scheduler.create_poll(context[:event], @poll_valid_attrs_1)
    {:ok, poll2} = Scheduler.create_poll(context[:event], @poll_valid_attrs_2)
    %{polls: [poll1, poll2]}
  end

  defp atomize_keys(map) do
    map
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    |> Map.new()
  end

  describe "index" do
    setup [:create_event, :create_polls]

    test "fetches all polls for event if owner token is passed", %{
      conn: conn,
      event: event,
      polls: polls
    } do
      conn = get(conn, event_poll_path(conn, :index, event.id), %{secret: event.secret})
      assert length(json_response(conn, 200)["data"]) == 2
      data = json_response(conn, 200)["data"]

      assert MapSet.new(for poll <- data, do: poll["id"]) ==
               MapSet.new(for poll <- polls, do: poll.id)
    end

    test "does not fetch any polls for event if owner token is wrong", %{conn: conn, event: event} do
      assert_error_sent(:not_found, fn ->
        get(conn, event_poll_path(conn, :index, event.id), %{secret: "wrong token"})
      end)
    end

    test "fetches a poll by participant", %{conn: conn, event: event, polls: polls} do
      [poll | _] = polls
      conn = get(conn, event_poll_path(conn, :index, event.id), %{participant: poll.participant})
      data = json_response(conn, 200)["data"]
      assert data["id"] == poll.id
    end

    test "does not fetch any polls for event if participant is wrong", %{conn: conn, event: event} do
      assert_error_sent(:not_found, fn ->
        get(conn, event_poll_path(conn, :index, event.id), %{
          participant: "nonexistent participant"
        })
      end)
    end
  end

  describe "show" do
    setup [:create_event, :create_polls]

    test "fetches a poll via its id", %{conn: conn, polls: [poll | _]} do
      conn = get(conn, poll_path(conn, :show, poll.id))
      data = json_response(conn, 200)["data"]
      assert data["id"] == poll.id
    end

    test "fetching a poll via its id does not leak event owner token", %{
      conn: conn,
      polls: [poll | _]
    } do
      conn = get(conn, poll_path(conn, :show, poll.id))
      data = json_response(conn, 200)["data"]
      assert data["id"] == poll.id
      assert data["event"]
      refute data["event"]["secret"]
    end
  end

  describe "create" do
    setup :create_event

    test "can create a poll with valid parameters", %{conn: conn, event: event} do
      conn = post(conn, event_poll_path(conn, :create, event.id), %{poll: @poll_valid_attrs_1})
      data = json_response(conn, 201)["data"]
      assert Map.has_key?(data, "id")
      assert @poll_valid_attrs_1.participant == data["participant"]

      assert @poll_valid_attrs_1.date_ranks ==
               Enum.map(
                 data["date_ranks"],
                 &Map.drop(&1, ["inserted_at", "updated_at", "poll_id", "id"])
               )
               |> Enum.map(&atomize_keys/1)

      assert @poll_valid_attrs_1.preferences.weekday_ranks ==
               Enum.map(data["preferences"]["weekday_ranks"], &atomize_keys/1)
    end

    test "attemp to create a poll with invalid parameters renders errors", %{
      conn: conn,
      event: event
    } do
      conn = post(conn, event_poll_path(conn, :create, event.id), %{poll: @poll_invalid_attrs})
      errors = json_response(conn, 422)["errors"]
      assert Enum.count(errors["participant"]) == 1
    end
  end

  describe "update" do
    setup [:create_event, :create_polls]

    test "poll can be updated when parameters are valid", %{conn: conn, polls: [poll | _]} do
      conn = put(conn, poll_path(conn, :update, poll.id), %{poll: @poll_update_attrs_1})
      data = json_response(conn, 200)["data"]
      assert poll.id == data["id"]
      assert @poll_valid_attrs_1.participant == data["participant"]

      assert @poll_update_attrs_1.date_ranks ==
               Enum.map(
                 data["date_ranks"],
                 &Map.drop(&1, ["inserted_at", "updated_at", "poll_id", "id"])
               )
               |> Enum.map(&atomize_keys/1)

      assert @poll_update_attrs_1.preferences.weekday_ranks ==
               Enum.map(data["preferences"]["weekday_ranks"], &atomize_keys/1)
    end

    test "date ranks can be deleted when passing an empty array", %{conn: conn, polls: [poll | _]} do
      conn =
        put(conn, poll_path(conn, :update, poll.id), %{
          poll: Map.put(@poll_update_attrs_1, :date_ranks, [])
        })

      data = json_response(conn, 200)["data"]
      assert poll.id == data["id"]
      assert @poll_valid_attrs_1.participant == data["participant"]
      assert data["date_ranks"] == []

      assert @poll_update_attrs_1.preferences.weekday_ranks ==
               Enum.map(data["preferences"]["weekday_ranks"], &atomize_keys/1)
    end

    test "weekday ranks can be deleted when passing an empty map as preferences", %{
      conn: conn,
      polls: [poll | _]
    } do
      conn =
        put(conn, poll_path(conn, :update, poll.id), %{
          poll: Map.put(@poll_update_attrs_1, :preferences, %{})
        })

      data = json_response(conn, 200)["data"]
      assert poll.id == data["id"]
      assert @poll_valid_attrs_1.participant == data["participant"]

      assert @poll_update_attrs_1.date_ranks ==
               Enum.map(
                 data["date_ranks"],
                 &Map.drop(&1, ["inserted_at", "updated_at", "poll_id", "id"])
               )
               |> Enum.map(&atomize_keys/1)

      assert data["preferences"]["weekday_ranks"] == []
    end

    test "weekday ranks can be deleted when passing an empty array", %{
      conn: conn,
      polls: [poll | _]
    } do
      conn =
        put(conn, poll_path(conn, :update, poll.id), %{
          poll: Map.put(@poll_update_attrs_1, :preferences, %{weekday_ranks: []})
        })

      data = json_response(conn, 200)["data"]
      assert poll.id == data["id"]
      assert @poll_valid_attrs_1.participant == data["participant"]

      assert @poll_update_attrs_1.date_ranks ==
               Enum.map(
                 data["date_ranks"],
                 &Map.drop(&1, ["inserted_at", "updated_at", "poll_id", "id"])
               )
               |> Enum.map(&atomize_keys/1)

      assert data["preferences"]["weekday_ranks"] == []
    end

    test "attempt to update a poll with invalid parameters renders errors", %{
      conn: conn,
      polls: [poll | _]
    } do
      conn = put(conn, poll_path(conn, :update, poll.id), %{poll: @poll_update_invalid_attrs_1})
      errors = json_response(conn, 422)["errors"]
      assert Enum.count(errors["date_ranks"]) == 1
      assert Enum.count(errors["preferences"]["weekday_ranks"]) == 1
    end
  end

  describe "delete" do
    setup [:create_event, :create_polls]

    test "polls can be deleted", %{conn: conn, polls: [poll | _]} do
      conn = delete(conn, poll_path(conn, :delete, poll.id))
      assert response(conn, 204)

      assert_error_sent(:not_found, fn ->
        get(conn, poll_path(conn, :show, poll.id))
      end)
    end
  end
end
