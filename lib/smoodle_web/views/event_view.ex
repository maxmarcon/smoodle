defmodule SmoodleWeb.EventView do
  use SmoodleWeb, :view
  alias SmoodleWeb.EventView

  def render("index.json", %{events: events}) do
    %{data: render_many(events, EventView, "event.json")}
  end

  def render("show.json", %{event: event}) do
    %{data: render_one(event, EventView, "event.json")}
  end

  def render("event.json", %{event: event = %{owner_token: _}}) do
    event
    |> Map.delete(:__meta__)
    |> Map.merge(%{
      owner_link: page_url(SmoodleWeb.Endpoint, :manage, event.id, owner_token: event.owner_token),
      share_link: page_url(SmoodleWeb.Endpoint, :poll, event.id)
    })
  end

  def render("event.json", %{event: event}) do
    Map.delete(event, :__meta__)
  end
end
