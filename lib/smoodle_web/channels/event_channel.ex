defmodule SmoodleWeb.EventChannel do
  use Phoenix.Channel
  alias Smoodle.Repo
  alias Smoodle.Scheduler.Event
  alias Smoodle.Scheduler
  alias SmoodleWeb.EventView
  alias SmoodleWeb.ChangesetView
  alias Phoenix.Socket

  def join("event:" <> event_id, %{"secret" => secret}, socket) do
    try do
      case event = Repo.get_by(Event, id: event_id, secret: secret) do
        nil ->
          {:error, %{reason: "Event not found"}}

        _ ->
          {
            :ok,
            %{
              event:
                EventView.render("event.json", %{event: Repo.preload(event, :possible_dates)}),
              schedule: Scheduler.get_best_schedule(event, is_owner: true)
            },
            assign(socket, is_owner: true)
          }
      end
    rescue
      Ecto.Query.CastError -> {:error, %{reason: "Invalid event id"}}
    end
  end

  def join("event:" <> event_id, _message, socket) do
    try do
      case event = Repo.get(Event, event_id) do
        nil ->
          {:error, %{reason: "Event not found"}}

        _ ->
          {
            :ok,
            %{
              event:
                EventView.render("event.json", %{
                  event: Repo.preload(event, :possible_dates),
                  obfuscate: true
                }),
              schedule: Scheduler.get_best_schedule(event)
            },
            socket
          }
      end
    rescue
      Ecto.Query.CastError -> {:error, %{reason: "Invalid event id"}}
    end
  end

  intercept(["schedule_update", "event_update"])

  def handle_out(
        "schedule_update" = channel_event,
        %{schedule: schedule, public_participants: public_participants},
        socket
      ) do
    if socket.assigns[:is_owner] || public_participants do
      push(socket, channel_event, %{schedule: schedule})
    else
      push(socket, channel_event, %{schedule: Scheduler.maybe_obfuscate_schedule(schedule, true)})
    end

    {:noreply, socket}
  end

  def handle_out(
        "event_update" = channel_event,
        %{event: event, schedule: schedule} = payload,
        socket
      ) do
    if socket.assigns[:is_owner] do
      push(socket, channel_event, %{
        payload
        | event: EventView.render("event.json", %{event: event})
      })
    else
      push(
        socket,
        channel_event,
        %{
          event: EventView.render("event.json", %{event: event, obfuscate: true}),
          schedule: Scheduler.maybe_obfuscate_schedule(schedule, !event.public_participants)
        }
      )
    end

    {:noreply, socket}
  end

  def handle_in(
        "update_event",
        %{"event" => event_update},
        socket = %Socket{topic: "event:" <> event_id}
      ) do
    if socket.assigns[:is_owner] do
      event = Scheduler.get_event!(event_id)

      case Scheduler.update_event(event, event_update) do
        {:ok, event} ->
          {:reply, {:ok, %{event: EventView.render("event.json", %{event: event})}}, socket}

        {:error, changeset} ->
          {:reply,
           {:error, %{reason: "Invalid", errors: ChangesetView.translate_errors(changeset)}},
           socket}

        err ->
          {:reply, {:error, %{reason: err}}, socket}
      end
    else
      {:reply, {:error, %{reason: "Forbidden"}}, socket}
    end
  end
end
