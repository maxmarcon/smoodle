defmodule SmoodleWeb.PollController do
  use SmoodleWeb, :controller

  alias Smoodle.Scheduler
  alias Smoodle.Scheduler.Poll
  alias Smoodle.Repo

  action_fallback SmoodleWeb.FallbackController

	def index(conn, %{"event_id" => event_id, "owner_token" => owner_token}) do
		event = Scheduler.get_event!(event_id, owner_token)

    polls = Repo.preload(Scheduler.list_polls(event), :date_ranks)
    render(conn, "index.json", polls: polls)
  end

  def index(conn, %{"event_id" => event_id, "participant" => participant}) do
    poll = Repo.preload(Scheduler.get_poll!(event_id, participant), :date_ranks)
    render(conn, "show.json", poll: poll)
  end

  def create(conn, %{"event_id" => event_id, "poll" => poll_params}) do
		event = Scheduler.get_event!(event_id)

		with {:ok, poll = %Poll{}} <- Scheduler.create_poll(event, poll_params) do
		conn
     |> put_status(:created)
     |> put_resp_header("location", event_path(conn, :show, poll))
     # need to preload date_ranks for the case when the poll_params don't include any date ranks
     |> render("show.json", poll: Repo.preload(poll, :date_ranks))
    end
	end

	def show(conn, %{"id" => id}) do
    poll = Repo.preload(Scheduler.get_poll!(id), :date_ranks)
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

    with {:ok, %Poll{}} <- Scheduler.delete_poll(poll) do
      send_resp(conn, :no_content, "")
    end
  end
end