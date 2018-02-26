defmodule SmoodleWeb.PageController do
  use SmoodleWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
