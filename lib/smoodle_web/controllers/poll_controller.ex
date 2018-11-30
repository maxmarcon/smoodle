defmodule SmoodleWeb.PollController do
  use SmoodleWeb, :controller

  require Logger
  alias Smoodle.Scheduler
  alias Smoodle.Scheduler.Poll
  alias Smoodle.Repo

  action_fallback(SmoodleWeb.FallbackController)

  def index(conn, %{"event_id" => event_id, "secret" => secret}) do
    event = Scheduler.get_event!(event_id, secret)

    polls = Repo.preload(Scheduler.list_polls(event), :date_ranks)
    render(conn, :index, polls: polls)
  end

  def index(conn, %{"event_id" => event_id, "participant" => participant}) do
    poll = Repo.preload(Scheduler.get_poll!(event_id, participant), :date_ranks)
    render(conn, :show, poll: poll)
  end

  def create(conn, %{"event_id" => event_id, "poll" => poll_params}) do
    event = Scheduler.get_event!(event_id)

    with {:ok, poll = %Poll{}} <- Scheduler.create_poll(event, poll_params) do
      Logger.info("Created poll: #{poll}")
      # need to preload date_ranks for the case when the poll_params don't include any date ranks
      conn
      |> put_status(:created)
      |> put_resp_header("location", poll_path(conn, :show, poll))
      |> render(:show, poll: Repo.preload(poll, :date_ranks))
    end
  end

  def show(conn, %{"id" => id}) do
    poll =
      Scheduler.get_poll!(id)
      |> Repo.preload(:date_ranks)
      |> Repo.preload(:event)

    render(conn, :show, poll: poll)
  end

  def update(conn, %{"id" => id, "poll" => poll_params}) do
    poll = Scheduler.get_poll!(id)

    with {:ok, %Poll{} = poll} <- Scheduler.update_poll(poll, poll_params) do
      Logger.info("Updated poll: #{poll}")

      put_resp_header(conn, "location", poll_path(conn, :show, poll))
      |> render(:show, poll: poll)
    end
  end

  def delete(conn, %{"id" => id}) do
    poll = Scheduler.get_poll!(id)

    with {:ok, %Poll{} = poll} <- Scheduler.delete_poll(poll) do
      Logger.info("Deleted poll: #{poll}")
      send_resp(conn, :no_content, "")
    end
  end
end
