defmodule SmoodleWeb.PageControllerTest do
  use SmoodleWeb.ConnCase

  setup_all do
    index_file_path = Application.app_dir(:smoodle, "priv/static/index.html")
    unless File.exists?(index_file_path) do
      File.mkdir_p!("priv/static")
      File.write!(index_file_path, "<html></html>")
    end
    :ok
  end

  test "serves the webapp index.html", %{conn: conn} do
    conn = get(conn, "/anypath")
    assert html_response(conn, :ok)
  end
end
