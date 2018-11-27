defmodule SmoodleWeb.PollControllerTest do
  use SmoodleWeb.ConnCase

  alias Smoodle.Scheduler
  alias Smoodle.Scheduler.Poll
  alias Smoodle.Scheduler.Poll.Preferences

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

  defp match_poll(poll, api_poll, exclude \\ [])

  defp match_poll(%Poll{} = poll, api_poll, exclude) do
    match_poll(Map.from_struct(poll), api_poll, exclude)
  end

  defp match_poll(poll, api_poll, exclude) do
    exclude = [:__meta__, :date_ranks, :preferences, :event | exclude]

    Enum.each(poll, fn {key, val} ->
      if key in exclude do
        nil
      else
        val =
          cond do
            key in [:inserted_at, :updated_at] and !is_binary(val) and !is_nil(val) ->
              DateTime.to_iso8601(val)

            true ->
              val
          end

        assert val == api_poll[to_string(key)]
      end
    end)

    match_preferences(poll.preferences, api_poll["preferences"])
    match_date_ranks(poll.date_ranks, api_poll["date_ranks"])
  end

  def match_preferences(nil, nil) do
  end

  def match_preferences(%Preferences{} = preferences, api_preferences) do
    match_preferences(Map.from_struct(preferences), api_preferences)
  end

  def match_preferences(preferences, api_preferences) do
    Enum.each(preferences, fn {:weekday_ranks, weekday_ranks} ->
      assert length(weekday_ranks) == length(api_preferences["weekday_ranks"])

      Enum.each(weekday_ranks, fn wk ->
        api_wk =
          Enum.find(api_preferences["weekday_ranks"], fn api_wk ->
            api_wk["day"] == wk.day
          end)

        assert wk.rank == api_wk["rank"]
      end)
    end)
  end

  def match_date_ranks(date_ranks, api_date_ranks)
      when is_list(date_ranks) and is_list(api_date_ranks) do
    assert length(date_ranks) == length(api_date_ranks)

    normalize_date_rank = fn %{rank: rank, date_from: date_from, date_to: date_to} ->
      date_from =
        if is_binary(date_from) do
          date_from
        else
          Date.to_string(date_from)
        end

      date_to =
        if is_binary(date_to) do
          date_to
        else
          Date.to_string(date_to)
        end

      %{"rank" => rank, "date_from" => date_from, "date_to" => date_to}
    end

    assert Enum.sort(Enum.map(date_ranks, normalize_date_rank)) ==
             Enum.sort(
               Enum.map(
                 api_date_ranks,
                 &Map.drop(&1, ["inserted_at", "updated_at", "id", "poll_id"])
               )
             )
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

      Enum.each(polls, fn poll ->
        api_poll = Enum.find(data, &(&1["id"] == poll.id))
        match_poll(poll, api_poll)
      end)
    end

    test "does not fetch any polls for event if owner token is wrong", %{conn: conn, event: event} do
      assert_error_sent(:not_found, fn ->
        get(conn, event_poll_path(conn, :index, event.id), %{secret: "wrong token"})
      end)
    end

    test "fetches a poll by participant", %{conn: conn, event: event, polls: polls} do
      poll = hd(polls)
      conn = get(conn, event_poll_path(conn, :index, event.id), %{participant: poll.participant})
      data = json_response(conn, 200)["data"]
      match_poll(poll, data)
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
      match_poll(poll, data)
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
      conn = post(conn, event_poll_path(conn, :create, event), %{poll: @poll_valid_attrs_1})
      data = json_response(conn, 201)["data"]
      assert Map.has_key?(data, "id")

      location = List.first(get_resp_header(conn, "location"))
      assert location == poll_path(conn, :show, data["id"])

      match_poll(@poll_valid_attrs_1, data)
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
      conn = put(conn, poll_path(conn, :update, poll), %{poll: @poll_update_attrs_1})
      data = json_response(conn, 200)["data"]

      location = List.first(get_resp_header(conn, "location"))
      assert location == poll_path(conn, :show, poll)

      assert Map.has_key?(data, "id")
      assert Map.has_key?(data, "updated_at")

      match_poll(Map.merge(poll, @poll_update_attrs_1), data)
    end

    test "date ranks can be deleted when passing an empty array", %{conn: conn, polls: [poll | _]} do
      update = Map.put(@poll_update_attrs_1, :date_ranks, [])

      conn =
        put(conn, poll_path(conn, :update, poll.id), %{
          poll: update
        })

      data = json_response(conn, 200)["data"]

      location = List.first(get_resp_header(conn, "location"))
      assert location == poll_path(conn, :show, poll)

      assert Map.has_key?(data, "id")
      assert Map.has_key?(data, "updated_at")

      match_poll(Map.merge(poll, update), data)
    end

    test "weekday ranks can be deleted when passing an empty map as preferences", %{
      conn: conn,
      polls: [poll | _]
    } do
      update = Map.put(@poll_update_attrs_1, :preferences, %{})

      conn =
        put(conn, poll_path(conn, :update, poll.id), %{
          poll: update
        })

      data = json_response(conn, 200)["data"]

      location = List.first(get_resp_header(conn, "location"))
      assert location == poll_path(conn, :show, poll)

      assert Map.has_key?(data, "id")
      assert Map.has_key?(data, "updated_at")

      match_poll(Map.merge(poll, update), data)
    end

    test "weekday ranks can be deleted when passing an empty array", %{
      conn: conn,
      polls: [poll | _]
    } do
      update = Map.put(@poll_update_attrs_1, :preferences, %{weekday_ranks: []})

      conn =
        put(conn, poll_path(conn, :update, poll.id), %{
          poll: update
        })

      data = json_response(conn, 200)["data"]

      location = List.first(get_resp_header(conn, "location"))
      assert location == poll_path(conn, :show, poll)

      assert Map.has_key?(data, "id")
      assert Map.has_key?(data, "updated_at")

      match_poll(Map.merge(poll, update), data)
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
