defmodule SmoodleWeb.ErrorViewTest do
  use SmoodleWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.html" do
    assert render_to_string(SmoodleWeb.ErrorView, "404.html", []) =~ 
      "Sorry, the page you are looking for does not exist"
  end

  test "render 500.html" do
    assert render_to_string(SmoodleWeb.ErrorView, "500.html", []) =~
      "The server experienced an internal error"
  end

  test "render any other with message" do
    error_msg = "An error occurred"
    error_status = "505"
    assert render_to_string(SmoodleWeb.ErrorView, error_status <> ".html", %{reason: %{message: error_msg}}) =~
           "#{error_status} #{error_msg}"
  end

  test "render any other without message" do
    error_msg = "An error occurred"
    assert render_to_string(SmoodleWeb.ErrorView, "505.html", %{}) =~
           "The server experienced an internal error"
  end
end
