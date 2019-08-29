defmodule SmoodleWeb.EventView do
  use SmoodleWeb, :view
  alias SmoodleWeb.EventView

  def render("index.json", %{events: events}) do
    %{
      data:
        render_many(Enum.map(events, &%{&1 | secret: nil, email: nil}), EventView, "event.json")
    }
  end

  def render("show.json", %{event: event}) do
    %{data: render_one(event, EventView, "event.json")}
  end

  def render("event.json", %{event: event = %{secret: secret}}) when not is_nil(secret) do
    event
    |> render_common_fields
    |> Map.merge(%{
      owner_link: owner_link(event),
      share_link: share_link(event)
    })
  end

  def render("event.json", %{event: event}), do: render_common_fields(event)

  def render("schedule.json", %{schedule: schedule}) do
    %{data: schedule}
  end

  def owner_link(event) do
    page_url(SmoodleWeb.Endpoint, :event, event.id, s: event.secret)
  end

  def share_link(event) do
    page_url(SmoodleWeb.Endpoint, :event, event.id)
  end

  defp render_common_fields(event) do
    event
    |> Map.from_struct()
    |> Map.drop([:__meta__, :polls])
    |> maybe_drop_secret
    |> maybe_drop_email
  end

  defp maybe_drop_secret(event) do
    if is_nil(event[:secret]) do
      Map.delete(event, :secret)
    else
      event
    end
  end

  defp maybe_drop_email(event) do
    if is_nil(event[:email]) do
      Map.delete(event, :email)
    else
      event
    end
  end
end
