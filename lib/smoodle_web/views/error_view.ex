defmodule SmoodleWeb.ErrorView do
  use SmoodleWeb, :view

  @codes_with_own_pages ["404", "500"]

  def render(<<code::binary-size(3), _rest::binary>>, %{reason: %{message: message, plug_status: status}}) 
  when code not in @codes_with_own_pages do 
    render("generic.html", %{message: message, status: status})
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.html", assigns
  end
end
