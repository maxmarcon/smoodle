defmodule SmoodleWeb.PollView do
  use SmoodleWeb, :view
  alias SmoodleWeb.PollView
  alias SmoodleWeb.EventView

  def render("index.json", %{polls: polls}) do
    %{data: render_many(polls, PollView, "poll.json")}
  end

  def render("show.json", %{poll: poll}) do
    %{data: render_one(poll, PollView, "poll.json")}
  end

  def render("poll.json", %{poll: poll}) do
    poll
    |> Map.from_struct()
    |> Map.drop([:__meta__])
    |> drop_or_render_event
  end

  defp drop_or_render_event(poll) do
    if Ecto.assoc_loaded?(poll.event) do
      Map.update!(
        poll,
        :event,
        &render_one(%{&1 | secret: nil, email: nil}, EventView, "event.json")
      )
    else
      Map.delete(poll, :event)
    end
  end
end
