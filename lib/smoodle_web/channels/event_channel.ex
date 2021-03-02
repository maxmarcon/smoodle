defmodule SmoodleWeb.EventChannel do
  use Phoenix.Channel
  alias Smoodle.Repo

  def join("event:" <> event_id = topic, _message, socket) do
    case Repo.get_by(Event, event_id) do
      nil -> {:error, %{reason: "Event not found"}}
      _ -> {:ok, socket}
    end
  end
end
