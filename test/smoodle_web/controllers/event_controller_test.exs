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
    time_window_from: "2117-03-01",
    time_window_to: "2117-06-01",
    email: "bot@fake.com",
    email_confirmation: "bot@fake.com"
  }
  @create_attrs_2 %{
    name: "Dinner",
    desc: "Yummy!",
    organizer: "The Hoff",
    time_window_from: "2117-04-01",
    time_window_to: "2117-08-20",
    email: "bot@fake.com",
    email_confirmation: "bot@fake.com"
  }

  defp rest_repr(%{ scheduled_from: scheduled_from, scheduled_to: scheduled_to }) do
    {:ok, s_from} = NaiveDateTime.from_iso8601(scheduled_from)
    {:ok, s_to} = NaiveDateTime.from_iso8601(scheduled_to)
    %{
      "scheduled_from" => NaiveDateTime.to_iso8601(s_from),
      "scheduled_to" => NaiveDateTime.to_iso8601(s_to)
    }
  end

  defp rest_repr(attr) do
    %{
      "name" => attr[:name],
      "desc" => attr[:desc],
      "time_window_from" => attr[:time_window_from],
      "time_window_to" => attr[:time_window_to],
      "organizer" => attr[:organizer],
      "email" => attr[:email]
    }
  end

  @update_attrs %{
    scheduled_from: "2117-04-05 21:10:00",
    scheduled_to: "2117-04-05 22:10:00",
    state: "SCHEDULED"
  }
  @invalid_attrs %{
    name: "",
    scheduled_to: "2117-04-05 21:10:00",
    scheduled_from: "2117-04-05 22:10:00"
  }
  #@partial_valid_data %{
  #  name: "Event"
  #}

  def create_event(_) do
    {:ok, event} = Scheduler.create_event(@create_attrs_1)
    {:ok, event: event}
  end

  def create_events(_) do
    {:ok, event1} = Scheduler.create_event(@create_attrs_1)
    {:ok, event2} = Scheduler.create_event(@create_attrs_2)
    {:ok, events: [event1, event2]}
  end

  describe "index" do
    setup :create_events

    @tag :skip
    test "lists all events", %{conn: conn, events: events} do
      conn = get conn, event_path(conn, :index)
      assert length(json_response(conn, 200)["data"]) == 2
      data = json_response(conn, 200)["data"]
      Enum.each(events, fn event ->
        from_data = Enum.find(data, &(&1["id"] == event.id))
        refute from_data == nil
        refute Map.has_key?(from_data, "secret")
        refute Map.has_key?(from_data, "email")
        assert event.name == from_data["name"]
        assert event.desc == from_data["desc"]
        assert Date.to_string(event.time_window_from) == from_data["time_window_from"]
        assert Date.to_string(event.time_window_to) == from_data["time_window_to"]
      end)
    end
  end

  describe "show" do
    setup :create_event

    test "returns 404 if called with the wrong secret", %{conn: conn, event: event} do
      assert_error_sent(404, fn ->
        get conn, event_path(conn, :show, event.id, %{secret: "wrong secret"})
      end)
    end

    test "fetches the event when called with the right secret", %{conn: conn, event: event} do
      conn = get conn, event_path(conn, :show, event.id, %{secret: event.secret})
      data_response = json_response(conn, 200)["data"]
      assert event.secret == data_response["secret"]
      assert event.email == data_response["email"]
      assert event.name == data_response["name"]
      assert event.desc == data_response["desc"]
      assert Date.to_string(event.time_window_from) == data_response["time_window_from"]
      assert Date.to_string(event.time_window_to) == data_response["time_window_to"]
    end
  end

  describe "create event" do
    setup do
      Cachex.reset(:mailer_cache)
      :ok
    end

    test "renders event when data is valid", %{conn: conn} do
      conn = post conn, event_path(conn, :create), event: @create_attrs_1
      data_response = json_response(conn, 201)["data"]
      assert %{"id" => id} = data_response
      assert Map.has_key?(data_response, "secret")
      assert data_response["email"] == @create_attrs_1.email

      expected_data_response = Map.merge(%{"id" => id}, rest_repr(@create_attrs_1))
      assert MapSet.subset?(MapSet.new(expected_data_response), MapSet.new(data_response))

      conn = get conn, event_path(conn, :show, id)
      data_response = json_response(conn, 200)["data"]
      assert MapSet.subset?(MapSet.new(Map.delete(expected_data_response, "email")), MapSet.new(data_response))
      refute Map.has_key?(data_response, "secret")
      refute Map.has_key?(data_response, "email")
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, event_path(conn, :create), event: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "after creating an event an email is sent to the organizer with a private link", %{conn: conn} do
      conn = post conn, event_path(conn, :create), event: @create_attrs_1
      data_response = json_response(conn, 201)["data"]

      event = struct(Event, (for {key, val} <- data_response, into: %{}, do: {String.to_atom(key), val}))
      email =  SmoodleWeb.Email.new_event_email(event)

      assert email.html_body =~ data_response["owner_link"]
      assert_delivered_email(email)
    end

    test "if too many emails were sent, no email is sent and event creation is rolled back", %{conn: conn} do
      {max_emails, bucket_duration} = Application.get_env(:smoodle, Smoodle.Mailer)[:rate_limit]

      for n <- 0..max_emails-1 do
        conn = post conn, event_path(conn, :create), event: @create_attrs_1
        json_response(conn, 201)
      end

      event_count = Repo.one(from e in Event, select: count(e.id))
      assert event_count == max_emails

      conn = post conn, event_path(conn, :create), event: @create_attrs_1
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

    #test "returns empty ok response for partially valid data and partial validation", %{conn: conn} do
    #  conn = post conn, event_path(conn, :create), event: @partial_valid_data, dry_run: true, partial: true
    #  assert "" = response(conn, 200)
    #end
  end

  describe "update event" do
    setup :create_event

    test "renders event when data is valid", %{conn: conn, event: %Event{id: id} = event} do
      conn = put conn, event_path(conn, :update, event), event: Map.merge(@update_attrs, %{secret: event.secret})
      data_response = json_response(conn, 200)["data"]
      assert %{"id" => ^id} = data_response
      assert Map.has_key?(data_response, "secret")

      expected_data_response = Map.merge(%{"id" => id}, rest_repr(@create_attrs_1)) |> Map.merge(rest_repr(@update_attrs))
      assert MapSet.subset?(MapSet.new(expected_data_response), MapSet.new(data_response))

      conn = get conn, event_path(conn, :show, event.id)
      data_response = json_response(conn, 200)["data"]
      assert MapSet.subset?(MapSet.new(Map.delete(Map.merge(%{"id" => id}, rest_repr(@create_attrs_1)), "email")), MapSet.new(data_response))
      refute Map.has_key?(data_response, "secret")
      refute Map.has_key?(data_response, "email")
    end

    test "renders errors when data is invalid", %{conn: conn, event: event} do
      conn = put conn, event_path(conn, :update, event), event: Map.merge(@invalid_attrs, %{secret: event.secret})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when secret is wrong", %{conn: conn, event: event} do
      assert_error_sent 404, fn ->
        put conn, event_path(conn, :update, event), event: Map.merge(@update_attrs, %{secret: "wrong_secret"})
      end
    end

  end

  describe "delete event" do
    setup :create_event

    test "deletes chosen event", %{conn: conn, event: event} do
      conn = delete conn, event_path(conn, :delete, event), secret: event.secret
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, event_path(conn, :show, event)
      end
    end

    test "does not delete and render error if secret is wrong", %{conn: conn, event: event} do
      assert_error_sent 404, fn ->
        delete conn, event_path(conn, :delete, event), secret: "wrong secret"
      end
      conn = get conn, event_path(conn, :show, event)
      assert response(conn, 200)
    end
  end

  describe "get_schedule" do
    setup :create_event

    test "returns the best schedule", %{conn: conn, event: event} do
      conn = get conn, event_path(conn, :schedule, event)
      data_response = json_response(conn, 200)
      assert Map.has_key?(data_response, "data")
    end

    test "returns 404 if called with wrong secret", %{conn: conn, event: event} do
      assert_error_sent(404, fn ->
        get conn, event_path(conn, :schedule, event), %{secret: "wrong_secret"}
      end)
    end

    test "returns the best schedule if called with the right secret", %{conn: conn, event: event} do
      conn = get conn, event_path(conn, :schedule, event), %{secret: event.secret}
      data_response = json_response(conn, 200)
      assert Map.has_key?(data_response, "data")
    end

    test "does not break if called with bogus limit", %{conn: conn, event: event} do
      conn = get conn, event_path(conn, :schedule, event), %{limit: "bogus!"}
      data_response = json_response(conn, 200)
      assert Map.has_key?(data_response, "data")
    end
  end
end
