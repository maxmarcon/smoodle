defmodule SmoodleWeb.PageController do
  use SmoodleWeb, :controller

  def app(conn, _params) do
    Plug.Conn.put_resp_content_type(conn, "text/html")
    |> Plug.Conn.send_file(:ok, Application.app_dir(:smoodle, "priv/static/index.html"))
  end

  def home(conn, params), do: app(conn, params)
  def event_edit(conn, params), do: app(conn, params)
  def event_new(conn, params), do: app(conn, params)
  def poll(conn, params), do: app(conn, params)
  def event(conn, params), do: app(conn, params)

  def redirect_to_home(conn, _params) do
    redirect(conn, to: "/home")
  end
end
