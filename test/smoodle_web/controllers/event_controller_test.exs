defmodule SmoodleWeb.EventControllerTest do
  use SmoodleWeb.ConnCase

  alias Smoodle.Scheduler
  alias Smoodle.Scheduler.Event

  @create_attrs_1 %{
    name: "Party",
    desc: "Yeah!",
    time_window_from: "2017-03-01",
    time_window_to: "2017-06-01"
  }
  @create_attrs_2 %{
    name: "Dinner",
    desc: "Yummy!",
    time_window_from: "2017-04-01",
    time_window_to: "2017-08-20"
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
      "time_window_to" => attr[:time_window_to]
    }
  end

  @update_attrs %{
    scheduled_from: "2017-04-05 21:10:00",
    scheduled_to: "2017-04-05 22:10:00"
  }
  @invalid_attrs %{
    scheduled_to: "2017-04-05 21:10:00",
    scheduled_from: "2017-04-05 22:10:00"    
  }

  def fixture(:event) do
    {:ok, event} = Scheduler.create_event(@create_attrs_1)
    {:ok, event: event}
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
        from_data = Enum.find(data, &(&1["id"] == event.id))
        refute from_data == nil
        refute Map.has_key?(from_data, "update_token")
        assert event.name == from_data["name"]
        assert event.desc == from_data["desc"]
        assert Date.to_string(event.time_window_from) == from_data["time_window_from"]
        assert Date.to_string(event.time_window_to) == from_data["time_window_to"]
      end)
    end
  end

  describe "create event" do
    test "renders event when data is valid", %{conn: conn} do
      conn = post conn, event_path(conn, :create), event: @create_attrs_1
      data_response = json_response(conn, 201)["data"]
      assert %{"id" => id} = data_response
      assert Map.has_key?(data_response, "update_token")

      expected_data_response = Map.merge(%{"id" => id}, rest_repr(@create_attrs_1))
      assert MapSet.subset?(MapSet.new(expected_data_response), MapSet.new(data_response))

      conn = get conn, event_path(conn, :show, id)
      data_response = json_response(conn, 200)["data"] 
      assert MapSet.subset?(MapSet.new(expected_data_response), MapSet.new(data_response))
      refute Map.has_key?(data_response, "update_token")
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, event_path(conn, :create), event: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update event" do
    setup do
      fixture(:event)
    end

    test "renders event when data is valid", %{conn: conn, event: %Event{id: id} = event} do
      conn = put conn, event_path(conn, :update, event), event: Map.merge(@update_attrs, %{update_token: event.update_token})
      data_response = json_response(conn, 200)["data"]
      assert %{"id" => ^id} = data_response
      refute Map.has_key?(data_response, "update_token")

      expected_data_response = Map.merge(%{"id" => id}, rest_repr(@create_attrs_1)) |> Map.merge(rest_repr(@update_attrs))
      assert MapSet.subset?(MapSet.new(expected_data_response), MapSet.new(data_response))

      conn = get conn, event_path(conn, :show, event.id)
      data_response = json_response(conn, 200)["data"]
      assert MapSet.subset?(MapSet.new(Map.merge(%{"id" => id}, rest_repr(@create_attrs_1))), MapSet.new(data_response))
      refute Map.has_key?(data_response, "update_token")
    end

    test "renders errors when data is invalid", %{conn: conn, event: event} do
      conn = put conn, event_path(conn, :update, event), event: Map.merge(@invalid_attrs, %{update_token: event.update_token})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when token is wrong", %{conn: conn, event: event} do
      assert_error_sent 404, fn ->
        put conn, event_path(conn, :update, event), event: Map.merge(@update_attrs, %{update_token: "wrong_token"})
      end
    end

  end

  describe "delete event" do
    setup do
      fixture(:event)
    end

    test "deletes chosen event", %{conn: conn, event: event} do
      conn = delete conn, event_path(conn, :delete, event), update_token: event.update_token
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, event_path(conn, :show, event)
      end
    end

    test "does not delete and render error if token is wrong", %{conn: conn, event: event} do
      assert_error_sent 404, fn ->
        delete conn, event_path(conn, :delete, event), update_token: "wrong token"
      end
      conn = get conn, event_path(conn, :show, event)
      assert response(conn, 200)
    end
  end
end
