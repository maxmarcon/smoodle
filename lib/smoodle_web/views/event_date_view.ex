defmodule SmoodleWeb.EventDateView do
  use SmoodleWeb, :view

  def render("event_date.json", %{event_date: event_date}) do
    Map.drop(event_date, [:__meta__, :event, :updated_at, :inserted_at, :event_id, :id])
  end
end
