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

  def call(conn, {:error, reason_atom}) do
    code = Plug.Conn.Status.code(reason_atom)

    conn
    |> put_status(reason_atom)
    |> render(SmoodleWeb.ErrorView, "#{code}.json", %{
      reason: %{message: Plug.Conn.Status.reason_phrase(code)}
    })
  end
end
