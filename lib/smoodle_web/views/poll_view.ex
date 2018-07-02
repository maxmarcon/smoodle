defmodule SmoodleWeb.PollView do
  use SmoodleWeb, :view
  alias SmoodleWeb.PollView
  alias SmoodleWeb.DateRankView

  def render("index.json", %{polls: polls}) do
    %{data: render_many(polls, PollView, "poll.json")}
  end

  def render("show.json", %{poll: poll}) do
    %{data: render_one(poll, PollView, "poll.json")}
  end

  def render("poll.json", %{poll: poll}) do
    poll
    |> Map.drop([:__meta__, :event])
    |> Map.update(:date_ranks, [], fn date_ranks ->
      render_many(date_ranks, DateRankView, "date_rank.json")
    end)
  end
end
