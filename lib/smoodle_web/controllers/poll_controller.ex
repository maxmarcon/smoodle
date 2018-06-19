defmodule SmoodleWeb.PollController do
  use SmoodleWeb, :controller

  alias Smoodle.Scheduler
  alias Smoodle.Scheduler.Poll
  action_fallback SmoodleWeb.FallbackController

	def index(conn, %{"event_id" => event_id, "owner_token" => owner_token}) do
		event = Scheduler.get_event!(event_id, owner_token)

    polls = Scheduler.list_polls(event)
    render(conn, "index.json", polls: polls)
  end

  def create(conn, %{"event_id" => event_id, "poll" => poll_params}) do
		event = Scheduler.get_event!(event_id)

		with {:ok, poll = %Poll{}} <- Scheduler.create_poll(event, poll_params) do
		conn
     |> put_status(:created)
     |> put_resp_header("location", event_path(conn, :show, poll))
     |> render("show.json", poll: poll)
    end
	end

	def show(conn, %{"id" => id}) do
    poll = Scheduler.get_poll!(id)
    render(conn, "show.json", poll: poll)
  end

	def show(conn, %{"event_id" => event_id, "participant" => participant}) do
    poll = Scheduler.get_poll!(event_id, participant)
    render(conn, "show.json", poll: poll)
  end

  def update(conn, %{"id" => id, "poll" => poll_params}) do
    poll = Scheduler.get_poll!(id)

    with {:ok, %Poll{} = poll} <- Scheduler.update_poll(poll, poll_params) do
      render(conn, "show.json", poll: poll)
    end
  end

  def delete(conn, %{"id" => id}) do
    poll = Scheduler.get_poll!(id)

    with {:ok, %Poll{}} <- Scheduler.delete_event(poll) do
      send_resp(conn, :no_content, "")
    end
  end
end