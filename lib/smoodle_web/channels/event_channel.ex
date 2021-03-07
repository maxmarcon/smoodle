defmodule SmoodleWeb.EventChannel do
  use Phoenix.Channel
  alias Smoodle.Repo
  alias Smoodle.Scheduler.Event
  alias Smoodle.Scheduler

  def join("event:" <> event_id, %{"secret" => secret}, socket) do
    try do
      case Repo.get_by(Event, id: event_id, secret: secret) do
        nil ->
          {:error, %{reason: "Event not found"}}

        _ ->
          {:ok, assign(socket, :is_owner, true)}
      end
    rescue
      Ecto.Query.CastError -> {:error, %{reason: "Invalid event id"}}
    end
  end

  def join("event:" <> event_id, message, socket) do
    try do
      case Repo.get(Event, event_id) do
        nil ->
          {:error, %{reason: "Event not found"}}

        _ ->
          {:ok, assign(socket, :is_owner, false)}
      end
    rescue
      Ecto.Query.CastError -> {:error, %{reason: "Invalid event id"}}
    end
  end

  intercept(["schedule_updated"])

  def handle_out("schedule_updated" = event, %{schedule: schedule} = payload, socket) do
    if socket.assigns[:is_owner] do
      push(socket, event, payload)
    else
      push(socket, event, %{schedule: Scheduler.remove_participants(schedule)})
    end

    {:noreply, socket}
  end
end
