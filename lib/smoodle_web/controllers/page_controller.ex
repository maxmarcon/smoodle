defmodule SmoodleWeb.PageController do
  use SmoodleWeb, :controller

  def index(conn, _params) do
    raise %Plug.BadRequestError{message: "Oh no, we did baaad!!!"}
  end
end
