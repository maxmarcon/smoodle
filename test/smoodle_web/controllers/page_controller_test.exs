defmodule SmoodleWeb.PageControllerTest do
  use SmoodleWeb.ConnCase

  @app_paths [
    "/home",
    "/events/new",
    "/events/:event_id/edit",
    "/events/:event_id/polls/new",
    "/events/:event_id",
    "/polls/:poll_id/edit"
  ]

  setup_all do
    index_file_path = Application.app_dir(:smoodle, "priv/static/index.html")
    unless File.exists?(index_file_path) do
      :ok = File.write(index_file_path, "<html></html>")
    end
  end

  test "app pages are rendered", %{conn: conn} do
    for path <- @app_paths do
      conn = get(conn, path)
      assert html_response(conn, :ok)
    end
  end

  test "/ is redirected to the home page", %{conn: conn} do
    assert redirected_to(get(conn, "/")) == "/home"
  end
end
