defmodule SmoodleWeb.EventControllerTest do
  use SmoodleWeb.ConnCase

  alias Smoodle.Scheduler
  alias Smoodle.Scheduler.Event

  @create_attrs_1 %{
    name: "Party",
    desc: "Yeah!",
    time_window_from: "2017-03-01",
    time_window_to: "2017-06-01",
    scheduled_from: "2017-03-20 20:10:00",
    scheduled_to: "2017-03-20 23:10:00"
  }
  @create_attrs_2 %{
    name: "Dinner",
    desc: "Yummy!",
    time_window_from: "2017-04-01",
    time_window_to: "2017-08-20",
    scheduled_from: "2017-07-21 21:10:00",
    scheduled_to: "2017-07-22 22:10:00"
  }

  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:event) do
    {:ok, event} = Scheduler.create_event(@create_attrs)
    event
  end

  def fixture(:events) do
    {:ok, event1} = Scheduler.create_event(@create_attrs_1)
    {:ok, event2} = Scheduler.create_event(@create_attrs_2)
    {:ok, events: [event1, event2]}
  end

  setup %{conn: conn} do
   {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup do
      fixture(:events)
    end

    test "lists all events", %{conn: conn, events: events} do
      conn = get conn, event_path(conn, :index)
      assert length(json_response(conn, 200)["data"]) == 2
      data = json_response(conn, 200)["data"]
      Enum.each(events, fn event ->
        assert event.name in Enum.map(data, &(&1["name"]))
        assert event.desc in Enum.map(data, &(&1["desc"]))
        assert Date.to_string(event.time_window_from) in Enum.map(data, &(&1["time_window_from"]))
        assert Date.to_string(event.time_window_to) in Enum.map(data, &(&1["time_window_to"]))
      end)
    end
  end

  describe "create event" do
    test "renders event when data is valid", %{conn: conn} do
      conn = post conn, event_path(conn, :create), event: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, event_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, event_path(conn, :create), event: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update event" do
    setup [:create_event]

    test "renders event when data is valid", %{conn: conn, event: %Event{id: id} = event} do
      conn = put conn, event_path(conn, :update, event), event: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, event_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id}
    end

    test "renders errors when data is invalid", %{conn: conn, event: event} do
      conn = put conn, event_path(conn, :update, event), event: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete event" do
    setup [:create_event]

    test "deletes chosen event", %{conn: conn, event: event} do
      conn = delete conn, event_path(conn, :delete, event)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, event_path(conn, :show, event)
      end
    end
  end

  defp create_event(_) do
    event = fixture(:event)
    {:ok, event: event}
  end
end
