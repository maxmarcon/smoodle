defmodule SmoodleWeb.EventControllerTest do
  use SmoodleWeb.ConnCase
  use Bamboo.Test

  alias Smoodle.Scheduler
  alias Smoodle.Scheduler.Event
  alias Smoodle.Scheduler.Event.Preferences

  import Ecto.Query
  alias Smoodle.Repo

  @create_attrs_1 %{
    name: "Party",
    desc: "Yeah!",
    organizer: "The Hoff",
    time_window_from: "2117-03-01",
    time_window_to: "2117-06-01",
    preferences: %{
      weekdays: [
        %{
          day: 5,
          permitted: true
        },
        %{
          day: 6,
          permitted: true
        }
      ]
    },
    email: "bot@fake.com",
    email_confirmation: "bot@fake.com"
  }
  @create_attrs_2 %{
    name: "Dinner",
    desc: "Yummy!",
    organizer: "The Hoff",
    time_window_from: "2117-04-01",
    time_window_to: "2117-08-20",
    preferences: nil,
    email: "bot@fake.com",
    email_confirmation: "bot@fake.com"
  }

  @update_attrs %{
    scheduled_from: "2117-04-05T21:10:00Z",
    scheduled_to: "2117-04-05T22:10:00Z",
    state: "SCHEDULED"
  }
  @invalid_attrs %{
    name: "",
    scheduled_to: "2117-04-05T21:10:00Z",
    scheduled_from: "2117-04-05T22:10:00Z"
  }

  # @partial_valid_data %{
  #  name: "Event"
  # }

  defp match_event(event, api_event, exclude \\ [])

  defp match_event(%Event{} = event, api_event, exclude) do
    match_event(Map.from_struct(event), api_event, exclude)
  end

  defp match_event(event, api_event, exclude) when is_map(event) and is_map(api_event) do
    exclude = [:__meta__, :polls, :preferences | exclude]

    Enum.each(event, fn {key, val} ->
      if key in exclude do
        nil
      else
        val =
          cond do
            key in [:scheduled_from, :scheduled_to, :inserted_at, :updated_at] and !is_binary(val) and
                !is_nil(val) ->
              DateTime.to_iso8601(val)

            key in [:time_window_from, :time_window_to] and !is_binary(val) and !is_nil(val) ->
              Date.to_string(val)

            true ->
              val
          end

        assert val == api_event[to_string(key)]
      end
    end)

    match_preferences(event.preferences, api_event["preferences"])
  end

  defp match_preferences(nil, nil) do
  end

  defp match_preferences(%Preferences{} = preferences, api_preferences) do
    match_preferences(Map.from_struct(preferences), api_preferences)
  end

  defp match_preferences(preferences, api_preferences) do
    Enum.each(preferences, fn {:weekdays, weekdays} ->
      assert length(weekdays) == length(api_preferences["weekdays"])

      Enum.each(weekdays, fn wk ->
        api_wk =
          Enum.find(api_preferences["weekdays"], fn api_wk ->
            api_wk["day"] == wk.day
          end)

        assert wk.permitted == api_wk["permitted"]
      end)
    end)
  end

  defp create_event(_) do
    {:ok, event} = Scheduler.create_event(@create_attrs_1)
    {:ok, event: event}
  end

  defp create_closed_event(_) do
    {:ok, event} = Scheduler.create_event(@create_attrs_1)
    {:ok, event: event}
  end

  defp create_events(_) do
    {:ok, event1} = Scheduler.create_event(@create_attrs_1)
    {:ok, event2} = Scheduler.create_event(@create_attrs_2)
    {:ok, events: [event1, event2]}
  end

  describe "index" do
    setup :create_events

    test "lists all events", %{conn: conn, events: events} do
      conn = get(conn, event_path(conn, :index))
      assert length(json_response(conn, 200)["data"]) == 2
      data = json_response(conn, 200)["data"]

      Enum.each(events, fn event ->
        api_event = Enum.find(data, &(&1["id"] == event.id))
        refute Map.has_key?(api_event, "secret")
        refute Map.has_key?(api_event, "email")
        match_event(event, api_event, [:email, :secret])
      end)
    end
  end

  describe "show" do
    setup :create_event

    test "returns 404 if called with the wrong secret", %{conn: conn, event: event} do
      assert_error_sent(404, fn ->
        get(conn, event_path(conn, :show, event.id, %{secret: "wrong secret"}))
      end)
    end

    test "fetches the event when called with the right secret", %{conn: conn, event: event} do
      conn = get(conn, event_path(conn, :show, event.id, %{secret: event.secret}))
      data_response = json_response(conn, 200)["data"]
      match_event(event, data_response)
    end

    test "fetches the event without secret", %{conn: conn, event: event} do
      conn = get(conn, event_path(conn, :show, event.id))
      data_response = json_response(conn, 200)["data"]
      match_event(event, data_response, [:email, :secret])
    end
  end

  describe "create event" do
    setup do
      Smoodle.Mailer.reset_counters()
      :ok
    end

    test "renders event when data is valid", %{conn: conn} do
      conn = post(conn, event_path(conn, :create), event: @create_attrs_1)
      data = json_response(conn, 201)["data"]
      assert Map.has_key?(data, "id")
      assert Map.has_key?(data, "secret")

      location = List.first(get_resp_header(conn, "location"))
      assert location == event_path(conn, :show, data["id"])

      match_event(@create_attrs_1, data, [:email_confirmation])
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, event_path(conn, :create), event: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "after creating an event an email is sent to the organizer with a private link", %{
      conn: conn
    } do
      conn = post(conn, event_path(conn, :create), event: @create_attrs_1)
      data_response = json_response(conn, 201)["data"]

      event =
        struct(Event, for({key, val} <- data_response, into: %{}, do: {String.to_atom(key), val}))

      email = SmoodleWeb.Email.new_event_email(event)

      assert email.html_body =~ data_response["owner_link"]
      assert_delivered_email(email)
    end

    test "if too many emails were sent, no email is sent and event creation is rolled back", %{
      conn: conn
    } do
      max_emails = Smoodle.Mailer.max_emails()

      for _ <- 0..(max_emails - 1) do
        conn = post(conn, event_path(conn, :create), event: @create_attrs_1)
        json_response(conn, 201)
      end

      event_count = Repo.one(from(e in Event, select: count(e.id)))
      assert event_count == max_emails

      conn = post(conn, event_path(conn, :create), event: @create_attrs_1)
      json_response(conn, 429)

      assert event_count == max_emails
    end

    # test "returns empty ok response when validating valid data", %{conn: conn} do
    #   conn = post conn, event_path(conn, :create), event: @create_attrs_1, dry_run: true
    #   assert "" = response(conn, 200)
    # end

    # test "renders errors when validating invalid data", %{conn: conn} do
    #   conn = post conn, event_path(conn, :create), event: @invalid_attrs, dry_run: true
    #   assert json_response(conn, 422)["errors"] != %{}
    # end

    # test "returns empty ok response for partially valid data and partial validation", %{conn: conn} do
    #  conn = post conn, event_path(conn, :create), event: @partial_valid_data, dry_run: true, partial: true
    #  assert "" = response(conn, 200)
    # end
  end

  describe "update event" do
    setup :create_event

    test "renders event when data is valid", %{conn: conn, event: %Event{} = event} do
      conn =
        put(
          conn,
          event_path(conn, :update, event),
          event: Map.merge(@update_attrs, %{secret: event.secret})
        )

      data = json_response(conn, 200)["data"]
      assert Map.has_key?(data, "id")
      assert Map.has_key?(data, "secret")
      assert Map.has_key?(data, "updated_at")
      location = List.first(get_resp_header(conn, "location"))
      assert location == event_path(conn, :show, data["id"])

      match_event(Map.merge(event, @update_attrs), data)
    end

    test "renders errors when data is invalid", %{conn: conn, event: event} do
      conn =
        put(
          conn,
          event_path(conn, :update, event),
          event: Map.merge(@invalid_attrs, %{secret: event.secret})
        )

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when secret is wrong", %{conn: conn, event: event} do
      assert_error_sent(404, fn ->
        put(
          conn,
          event_path(conn, :update, event),
          event: Map.merge(@update_attrs, %{secret: "wrong_secret"})
        )
      end)
    end
  end

  describe "delete event" do
    setup :create_event

    test "deletes chosen event", %{conn: conn, event: event} do
      conn = delete(conn, event_path(conn, :delete, event), secret: event.secret)
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, event_path(conn, :show, event))
      end)
    end

    test "does not delete and render error if secret is wrong", %{conn: conn, event: event} do
      assert_error_sent(404, fn ->
        delete(conn, event_path(conn, :delete, event), secret: "wrong secret")
      end)

      conn = get(conn, event_path(conn, :show, event))
      assert response(conn, 200)
    end
  end

  describe "get_schedule" do
    setup :create_event

    test "returns the best schedule", %{conn: conn, event: event} do
      conn = get(conn, event_path(conn, :schedule, event))
      data_response = json_response(conn, 200)
      assert Map.has_key?(data_response, "data")
    end

    test "returns 404 if called with wrong secret", %{conn: conn, event: event} do
      assert_error_sent(404, fn ->
        get(conn, event_path(conn, :schedule, event), %{secret: "wrong_secret"})
      end)
    end

    test "returns the best schedule if called with the right secret", %{conn: conn, event: event} do
      conn = get(conn, event_path(conn, :schedule, event), %{secret: event.secret})
      data_response = json_response(conn, 200)
      assert Map.has_key?(data_response, "data")
    end

    test "does not break if called with bogus limit", %{conn: conn, event: event} do
      conn = get(conn, event_path(conn, :schedule, event), %{limit: "bogus!"})
      data_response = json_response(conn, 200)
      assert Map.has_key?(data_response, "data")
    end
  end

  describe "get_schedule with closed event" do
    setup :create_closed_event

    test "returns an empty schedule", %{conn: conn, event: event} do
      conn = get(conn, event_path(conn, :schedule, event))
      data_response = json_response(conn, 200)
      assert Map.has_key?(data_response, "data")

      assert data_response["data"]["participants"] == []
      assert data_response["data"]["participants_count"] == 0
      assert data_response["data"]["dates"] == []
    end

    test "returns an empty schedule event with the right secret", %{conn: conn, event: event} do
      conn = get(conn, event_path(conn, :schedule, event), %{secret: event.secret})
      data_response = json_response(conn, 200)
      assert Map.has_key?(data_response, "data")

      assert data_response["data"]["participants"] == []
      assert data_response["data"]["participants_count"] == 0
      assert data_response["data"]["dates"] == []
    end
  end
end
