defmodule SmoodleWeb.EventController do
  use SmoodleWeb, :controller

  alias Smoodle.Scheduler
  alias Smoodle.Scheduler.Event

  action_fallback SmoodleWeb.FallbackController

  def index(conn, _params) do
    events = Scheduler.list_events()
    render(conn, "index.json", events: events)
  end

  def create(conn, %{"event" => event_params}) do
    with {:ok, %Event{} = event} <- Scheduler.create_event(event_params) do
     conn
     |> put_status(:created)
     |> put_resp_header("location", event_path(conn, :show, event))
     |> render("show.json", event: event, with_update_token: true)
    end
  end

  def show(conn, %{"id" => id}) do
    event = Scheduler.get_event!(id)
    render(conn, "show.json", event: event)
  end

  def update(conn, %{"id" => id, "event" => event_params = %{"update_token" => update_token}}) do
    event = Scheduler.get_event_for_update!(id, update_token)

    with {:ok, %Event{} = event} <- Scheduler.update_event(event, event_params) do
      render(conn, "show.json", event: event)
    end
  end

  def delete(conn, %{"id" => id, "update_token" => update_token}) do
    event = Scheduler.get_event_for_update!(id, update_token)
    
    with {:ok, %Event{}} <- Scheduler.delete_event(event) do
      send_resp(conn, :no_content, "")
    end
  end
end
