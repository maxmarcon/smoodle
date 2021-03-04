defmodule SmoodleWeb.EventChannel do
  use Phoenix.Channel
  alias Smoodle.Repo
  alias Smoodle.Scheduler.Event

  def join("event:" <> event_id = topic, _message, socket) do
    case Repo.get(Event, event_id) do
      nil -> {:error, %{reason: "Event not found"}}
      _ -> {:ok, socket}
    end
  end
end
