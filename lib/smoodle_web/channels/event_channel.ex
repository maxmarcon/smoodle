defmodule SmoodleWeb.EventChannel do
  use Phoenix.Channel
  alias Smoodle.Repo
  alias Smoodle.Scheduler.{Event, Poll}
  alias Smoodle.Scheduler
  alias SmoodleWeb.{EventView, PollView, ChangesetView}
  alias Phoenix.Socket

  def join("event:" <> event_id, message, socket) do
    secret = message["secret"]

    clauses =
      if secret do
        [secret: secret, id: event_id]
      else
        [id: event_id]
      end

    try do
      case event = Repo.get_by(Event, clauses) |> Repo.preload(:possible_dates) do
        nil ->
          {:error, %{reason: :not_found}}

        _ ->
          {
            :ok,
            %{
              event:
                EventView.render(
                  "event.json",
                  %{
                    event: event,
                    obfuscate: !secret
                  }
                ),
              schedule: Scheduler.get_best_schedule(event, is_owner: !!secret)
            },
            assign(socket, is_owner: !!secret)
          }
      end
    rescue
      Ecto.Query.CastError -> {:error, %{reason: :invalid_id}}
    end
  end

  intercept(["schedule_update", "event_update"])

  def handle_out(
        "schedule_update" = channel_event,
        %{schedule: schedule, public_participants: public_participants},
        socket
      ) do
    do_obfuscate = !socket.assigns[:is_owner] && !public_participants

    push(
      socket,
      channel_event,
      %{
        schedule: Scheduler.maybe_obfuscate_schedule(schedule, do_obfuscate)
      }
    )

    {:noreply, socket}
  end

  def handle_out(
        "event_update" = channel_event,
        %{event: event, schedule: schedule},
        socket
      ) do
    push(
      socket,
      channel_event,
      %{
        event:
          EventView.render("event.json", %{event: event, obfuscate: !socket.assigns[:is_owner]}),
        schedule:
          Scheduler.maybe_obfuscate_schedule(
            schedule,
            !event.public_participants && !socket.assigns[:is_owner]
          )
      }
    )

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
          {
            :reply,
            {:error, %{reason: :invalid, errors: ChangesetView.translate_errors(changeset)}},
            socket
          }

        err ->
          {:reply, {:error, %{reason: err}}, socket}
      end
    else
      {:reply, {:error, %{reason: :forbidden}}, socket}
    end
  end

  def handle_in(
        "get_poll",
        message,
        socket = %Socket{topic: "event:" <> event_id}
      ) do
    clause =
      Map.take(message, ["participant", "id"])
      |> Map.to_list()
      |> Enum.map(fn {key, val} -> {String.to_atom(key), val} end)
      |> Keyword.merge(event_id: event_id)

    poll =
      Repo.get_by(Poll, clause)
      |> Repo.preload(:date_ranks)
      |> Repo.preload(event: :possible_dates)

    if poll do
      {:reply, {:ok, %{poll: PollView.render("poll.json", %{poll: poll})}}, socket}
    else
      {:reply, {:error, %{reason: :not_found}}, socket}
    end
  end
end
