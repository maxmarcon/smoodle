defmodule SmoodleWeb.EventView do
  use SmoodleWeb, :view
  alias SmoodleWeb.EventView

  def render("index.json", %{events: events}) do
    %{data: render_many(events, EventView, "event.json")}
  end

  def render("show.json", %{event: event, with_update_token: true}) do
    %{data: render_one(event, EventView, "event_with_update_token.json")}
  end

  def render("show.json", %{event: event}) do
    %{data: render_one(event, EventView, "event.json")}
  end

  def render("event_with_update_token.json", %{event: event}) do
    Map.delete(event, :__meta__)
  end

  def render("event.json", %{event: event}) do
    Map.delete(event, :__meta__) |> Map.delete(:update_token)
  end
end
