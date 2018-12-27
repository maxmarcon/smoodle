defmodule SmoodleWeb.EventView do
  use SmoodleWeb, :view
  alias SmoodleWeb.EventView
  alias SmoodleWeb.EventDateView

  def render("index.json", %{events: events}) do
    %{data: render_many(Enum.map(events, &Map.delete(&1, :secret)), EventView, "event.json")}
  end

  def render("show.json", %{event: event}) do
    %{data: render_one(event, EventView, "event.json")}
  end

  def render("event.json", %{event: event = %{secret: _}}) do
    event
    |> Map.drop([:__meta__, :polls])
    |> Map.update(:possible_dates, [], &render_many(&1, EventDateView, "event_date.json"))
    |> Map.merge(%{
      owner_link: owner_link(event),
      share_link: share_link(event)
    })
  end

  def render("event.json", %{event: event}) do
    Map.drop(event, [:__meta__, :polls, :email, :secret])
    |> Map.update(:possible_dates, [], &render_many(&1, EventDateView, "event_date.json"))
  end

  def render("schedule.json", %{schedule: schedule}) do
    %{data: schedule}
  end

  def owner_link(event) do
    page_url(SmoodleWeb.Endpoint, :event, event.id, s: event.secret)
  end

  def share_link(event) do
    page_url(SmoodleWeb.Endpoint, :event, event.id)
  end
end
