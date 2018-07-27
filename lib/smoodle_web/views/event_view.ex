defmodule SmoodleWeb.EventView do
  use SmoodleWeb, :view
  alias SmoodleWeb.EventView

  def render("index.json", %{events: events}) do
    %{data: render_many(events, EventView, "event.json")}
  end

  def render("show.json", %{event: event}) do
    %{data: render_one(event, EventView, "event.json")}
  end

  def render("event.json", %{event: event = %{secret: _}}) do
    event
    |> Map.delete(:__meta__)
    |> Map.merge(%{
      owner_link: owner_link(event),
      share_link: share_link(event)
    })
  end

  def render("event.json", %{event: event}) do
    Map.drop(event, [:__meta__, :polls, :email])
  end

  def owner_link(event) do
    page_url(SmoodleWeb.Endpoint, :event, event.id, secret: event.secret)
  end

  def share_link(event) do
    page_url(SmoodleWeb.Endpoint, :event, event.id)
  end
end
