defmodule SmoodleWeb.ErrorView do
  use SmoodleWeb, :view

  @statuses_with_own_pages ["404", "500"]

  def render(<<status::binary-size(3), ".json">>, %{reason: %{message: message}}) do
    %{status: status, message: message}
  end

  def render(<<status::binary-size(3), ".html">>, %{reason: %{message: message}}) 
  when status not in @statuses_with_own_pages do 
    render("generic.html", %{message: message, status: status})
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.html", assigns
  end
end
