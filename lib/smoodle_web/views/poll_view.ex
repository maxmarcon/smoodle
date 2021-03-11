defmodule SmoodleWeb.PollView do
  use SmoodleWeb, :view
  alias SmoodleWeb.PollView

  def render("index.json", %{polls: polls}) do
    %{data: render_many(polls, PollView, "poll.json")}
  end

  def render("show.json", %{poll: poll}) do
    %{data: render_one(poll, PollView, "poll.json")}
  end

  def render("poll.json", %{poll: poll}) do
    maybe_nullify_event(poll)
  end

  defp maybe_nullify_event(poll) do
    if !Ecto.assoc_loaded?(poll.event) do
      %{poll | event: nil}
    else
      poll
    end
  end
end
