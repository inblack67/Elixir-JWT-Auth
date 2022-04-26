defmodule ExauthWeb.AuthController do
  use ExauthWeb, :controller
  alias Exauth.Accounts
  alias ExauthWeb.Utils

  def ping(conn, _params) do
    conn
    |> render("ack.json", %{success: true, message: "Pong"})
  end

  def register(conn, params) do
    case Accounts.create_user(params) do
      {:ok, _user} ->
        conn |> render("ack.json", %{success: true, message: "Registration Successful"})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn |> render("errors.json", %{errors: Utils.format_changeset_errors(changeset)})

      _ ->
        conn |> render("error.json", %{error: Utils.internal_server_error()})
    end
  end
end
