defmodule SmoodleWeb.PageController do
  use SmoodleWeb, :controller

  def welcome(conn, _params) do
  	render conn, "welcome.html"
  end

  def app(conn, _params) do
  	render conn, "app.html"
  end

  def new_event(conn, params), do: app(conn, params)
  def edit_event(conn, params), do: app(conn, params)
  def new_poll(conn, params), do: app(conn, params)
end
