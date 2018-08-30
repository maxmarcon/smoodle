defmodule SmoodleWeb.PageController do
  use SmoodleWeb, :controller

  def welcome(conn, _params) do
  	render conn, "welcome.html"
  end

  def app(conn, _params) do
  	render conn, "app.html"
  end

  def event_edit(conn, params), do: app(conn, params)
  def event_new(conn, params), do: app(conn, params)
  def poll(conn, params), do: app(conn, params)
  def event(conn, params), do: app(conn, params)
end
