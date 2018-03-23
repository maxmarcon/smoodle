defmodule SmoodleWeb.PageController do
  use SmoodleWeb, :controller

  def welcome(conn, _params) do
  	render conn, "welcome.html"
  end

  def app(conn, _params) do
  	render conn, "app.html"
  end
end
