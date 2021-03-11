defmodule SmoodleWeb.EventView do
  use SmoodleWeb, :view
  alias SmoodleWeb.EventView

  def render("index.json", %{events: events}) do
    %{
      data: render_many(events, EventView, "event.json")
    }
  end

  def render("show.json", %{event: event}) do
    %{data: render_one(event, EventView, "event.json")}
  end

  def render("event.json", %{event: event}), do: event

  def render("schedule.json", %{schedule: schedule}) do
    %{data: schedule}
  end
end
