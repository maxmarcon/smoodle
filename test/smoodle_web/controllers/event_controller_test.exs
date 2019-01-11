defmodule SmoodleWeb.EventControllerTest do
  use SmoodleWeb.ConnCase
  use Bamboo.Test

  alias Smoodle.Scheduler
  alias Smoodle.Scheduler.Event

  import Ecto.Query
  alias Smoodle.Repo

  @create_attrs_1 %{
    name: "Party",
    desc: "Yeah!",
    organizer: "The Hoff",
    possible_dates: [
      %{date_from: "2117-03-01", date_to: "2117-06-01", rank: 0}
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
          day: 3,
          rank: -1
        },
        %{
          day: 4,
          rank: -1
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
    possible_dates: [%{date_from: "2117-04-01", date_to: "2117-08-20", rank: 0}],
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

  defp check_event(data = %{}, verify = %{} \\ %{}) do
    assert Map.has_key?(data, "id")
    assert Map.has_key?(data, "preferences")

    unless is_nil(data["preferences"]) do
      assert is_map(data["preferences"])
    end

    assert Map.has_key?(data, "name")
    assert Map.has_key?(data, "desc")
    assert Map.has_key?(data, "organizer")
    assert Map.has_key?(data, "possible_dates")
    assert is_list(data["possible_dates"])
    refute Enum.empty?(data["possible_dates"])

    Enum.each(verify, fn {key, value} ->
      assert data[to_string(key)] == value
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
      event_list = json_response(conn, 200)["data"]

      assert for(event <- events, do: event.id) == for(data <- event_list, do: data["id"])

      Enum.each(event_list, fn data ->
        check_event(data)
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

      check_event(data_response, Map.take(event, [:id, :email, :secret]))
    end

    test "fetches the event without secret", %{conn: conn, event: event} do
      conn = get(conn, event_path(conn, :show, event.id))
      data_response = json_response(conn, 200)["data"]

      refute Map.has_key?(data_response, "secret")
      refute Map.has_key?(data_response, "email")

      check_event(data_response, Map.take(event, [:id]))
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

      location = List.first(get_resp_header(conn, "location"))
      assert location == event_path(conn, :show, data["id"])

      check_event(data, Map.take(@create_attrs_1, [:desc, :organizer, :name]))

      assert Map.has_key?(data, "secret")
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
      assert Map.has_key?(data, "updated_at")

      location = List.first(get_resp_header(conn, "location"))
      assert location == event_path(conn, :show, data["id"])

      check_event(data, @update_attrs)

      assert Map.has_key?(data, "secret")
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
