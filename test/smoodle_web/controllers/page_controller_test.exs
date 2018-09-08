defmodule SmoodleWeb.PageControllerTest do
  use SmoodleWeb.ConnCase

  import Phoenix.View

  @app_paths [
    "/home",
    "/events/new",
    "/events/:event_id/edit",
    "/events/:event_id/polls/new",
    "/events/:event_id",
    "/polls/:poll_id/edit"
  ]

  test "app pages are rendered", %{conn: conn} do
    for path <- @app_paths do
      conn = get(conn, path)
      assert html_response(conn, :ok) =~ render_to_string(SmoodleWeb.PageView, "app.html", [])
    end
  end

  test "/ is redirected to the home page", %{conn: conn} do
    assert redirected_to(get(conn, "/")) == "/home"
  end
end
