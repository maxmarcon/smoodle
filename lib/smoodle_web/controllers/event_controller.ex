defmodule SmoodleWeb.EventController do
  use SmoodleWeb, :controller

  alias Smoodle.Scheduler
  alias Smoodle.Scheduler.Event
  alias Smoodle.Mailer
  alias SmoodleWeb.Email

  require Logger
  action_fallback SmoodleWeb.FallbackController

  #def index(conn, _params) do
  #  events = Scheduler.list_events()
  #  render(conn, "index.json", events: events)
  #end

  #def create(_, %{"event" => event_params, "dry_run" => true} = params) do
  #  case Scheduler.create_event(event_params, dry_run: true) do
  #    %{:valid? => true} -> :ok
  #    # for partial validation, we return ok
  #    # if the errors only affect parameters that were not specified by the client
  #    changeset -> if params["partial"] &&
  #      Enum.empty?(Keyword.take(changeset.errors, Enum.map(Map.keys(event_params), &String.to_atom/1))) do
  #      :ok
  #    else
  #      {:error, changeset}
  #    end
  #  end
  #end

  def create(conn, %{"event" => event_params}) do
    with {:ok, %Event{} = event} <- Scheduler.create_event(event_params) do
      Email.new_event_email(event)
      |> Mailer.deliver_later

      Logger.info "Created event: #{event}"

      conn
      |> put_status(:created)
      |> put_resp_header("location", event_path(conn, :show, event))
      |> render("show.json", event: event)
    end
  end

  def show(conn, %{"id" => id, "secret" => secret}) do
    event = Scheduler.get_event!(id, secret)
    render(conn, "show.json", event: event)
  end

  def show(conn, %{"id" => id}) do
    event = Scheduler.get_event!(id)
    render(conn, "show.json", event: Map.delete(event, :secret))
  end

  def update(conn, %{"id" => id, "event" => event_params = %{"secret" => secret}}) do
    event = Scheduler.get_event!(id, secret)

    with {:ok, %Event{} = event} <- Scheduler.update_event(event, event_params) do
      Logger.info "Updated event: #{event}"
      render(conn, "show.json", event: event)
    end
  end

  def delete(conn, %{"id" => id, "secret" => secret}) do
    event = Scheduler.get_event!(id, secret)

    with {:ok, %Event{} = event} <- Scheduler.delete_event(event) do
      Logger.info "Deleted event: #{event}"
      send_resp(conn, :no_content, "")
    end
  end

  def schedule(conn, %{"id" => id, "secret" => secret} = params) do
    event = Scheduler.get_event!(id, secret)

    render(conn, "schedule.json", %{schedule: Scheduler.get_best_schedule(event, Keyword.merge(schedule_parse_params(params), is_owner: true))})
  end

  def schedule(conn, %{"id" => id} = params) do
    event = Scheduler.get_event!(id)

    render(conn, "schedule.json", %{schedule: Scheduler.get_best_schedule(event, schedule_parse_params(params))})
  end

  defp schedule_parse_params(params) do
    limit = with {number, _} <- Integer.parse(params["limit"] || "") do
      number
    else
      _ -> nil
    end

    [limit: limit]
  end

end
