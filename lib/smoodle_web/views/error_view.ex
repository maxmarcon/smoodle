defmodule SmoodleWeb.ErrorView do
  use SmoodleWeb, :view

  def render(<<code::binary-size(3), rest::binary>>, %{reason: %{message: message, plug_status: status}}) 
  when code not in ["404", "500"] do 
    render("generic.html", %{message: message, status: status})
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.html", assigns
  end
end
