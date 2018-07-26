defmodule SmoodleWeb.PollView do
  use SmoodleWeb, :view
  alias SmoodleWeb.PollView
  alias SmoodleWeb.DateRankView
  alias SmoodleWeb.EventView

  def render("index.json", %{polls: polls}) do
    %{data: render_many(polls, PollView, "poll.json")}
  end

  def render("show.json", %{poll: poll}) do
    %{data: render_one(poll, PollView, "poll.json")}
  end

  def render("poll.json", %{poll: poll}) do
    poll
    |> Map.drop([:__meta__])
    |> Map.update(:date_ranks, [], &render_many(&1, DateRankView, "date_rank.json"))
    |> Map.update(:event, nil, fn event ->
      if Ecto.assoc_loaded?(poll.event) do
        render_one(Map.drop(event, [:polls, :secret]), EventView, "event.json")
      else
        nil
      end
    end)
  end
end
