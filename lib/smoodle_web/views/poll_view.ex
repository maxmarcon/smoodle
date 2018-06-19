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
    Map.delete(poll, :__meta__)
  end
end
