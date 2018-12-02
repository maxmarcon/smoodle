defmodule SmoodleWeb.ErrorView do
  use SmoodleWeb, :view

  @statuses_with_own_pages ["404", "500"]

  def render(<<status::binary-size(3), ".json">>, %{}) do
    status =
      case Integer.parse(status) do
        {numeric_status, _} -> numeric_status
        _ -> 500
      end

    %{status: status, message: Plug.Conn.Status.reason_phrase(status)}
  end

  def render(<<status::binary-size(3), ".html">>, %{})
      when status not in @statuses_with_own_pages do
    status =
      case Integer.parse(status) do
        {numeric_status, _} -> numeric_status
        _ -> 500
      end

    render("generic.html", %{status: status, message: Plug.Conn.Status.reason_phrase(status)})
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render("500.html", assigns)
  end
end
