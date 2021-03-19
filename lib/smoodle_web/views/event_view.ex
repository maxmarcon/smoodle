defmodule SmoodleWeb.EventView do
  use SmoodleWeb, :view
  alias SmoodleWeb.EventView
  alias Smoodle.Scheduler.Event

  def render("index.json", %{events: events}) do
    %{
      data: render_many(events, EventView, "event.json")
    }
  end

  def render("show.json", %{event: event, obfuscate: obfuscate}) do
    %{data: render_one(event, EventView, "event.json", obfuscate: obfuscate)}
  end

  def render("show.json", %{event: event}) do
    %{data: render_one(event, EventView, "event.json")}
  end

  def render("event.json", %{event: event, obfuscate: true}) do
    %{event | secret: nil, email: nil}
  end

  def render("event.json", %{event: event}), do: add_links(event)

  def add_links(event) do
    %{event | owner_link: owner_link(event), share_link: share_link(event)}
  end

  defp owner_link(%Event{secret: secret, id: id})
       when is_binary(secret) and byte_size(secret) > 0 do
    page_url(SmoodleWeb.Endpoint, :event, id, s: secret)
  end

  defp share_link(%Event{id: id}) do
    page_url(SmoodleWeb.Endpoint, :event, id)
  end

  def render("schedule.json", %{schedule: schedule}) do
    %{data: schedule}
  end
end
