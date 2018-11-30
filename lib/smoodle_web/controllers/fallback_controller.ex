defmodule SmoodleWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use SmoodleWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(SmoodleWeb.ChangesetView)
    |> render(:error, changeset: changeset)
  end

  def call(conn, :ok) do
    send_resp(conn, :ok, "")
  end

  def call(conn, {:error, reason_atom}) when is_atom(reason_atom) do
    code = Plug.Conn.Status.code(reason_atom)

    conn
    |> put_status(reason_atom)
    |> put_view(SmoodleWeb.ErrorView)
    |> render("#{code}.json", %{
      reason: %{message: Plug.Conn.Status.reason_phrase(code)}
    })
  end
end
