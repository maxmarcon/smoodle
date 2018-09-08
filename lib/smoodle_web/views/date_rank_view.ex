defmodule SmoodleWeb.DateRankView do
  use SmoodleWeb, :view

  def render("date_rank.json", %{date_rank: date_rank}) do
    Map.drop(date_rank, [:__meta__, :poll])
  end
end
