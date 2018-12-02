defmodule SmoodleWeb.ErrorViewTest do
  use SmoodleWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.html" do
    assert render_to_string(SmoodleWeb.ErrorView, "404.html", []) =~
             "Sorry, the page you are looking for does not exist"
  end

  test "renders 500.html" do
    assert render_to_string(SmoodleWeb.ErrorView, "500.html", []) =~
             "The server experienced an internal error"
  end

  test "renders <STATUS>.html with known status" do
    assert render_to_string(SmoodleWeb.ErrorView, "409.html", []) =~ "Conflict"
  end

  test "renders <STATUS>.html with bogus status" do
    render_to_string(SmoodleWeb.ErrorView, "FOO.html", []) =~
      "The server experienced an internal error"
  end

  test "renders <STATUS>.json with known status" do
    assert render(SmoodleWeb.ErrorView, "404.json", []) == %{status: 404, message: "Not Found"}
  end

  test "render <STATUS>.json with bogus status" do
    assert render(SmoodleWeb.ErrorView, "FOO.json", []) == %{
             status: 500,
             message: "Internal Server Error"
           }
  end
end
