defmodule SmoodleWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use SmoodleWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(SmoodleWeb.ChangesetView, "error.json", changeset: changeset)
  end

  def call(conn, :ok) do
    send_resp(conn, :ok, "")
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(SmoodleWeb.ErrorView, "404.json", %{reason: %{message: "Not found"}})
  end
end
