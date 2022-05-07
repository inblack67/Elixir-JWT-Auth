defmodule ExauthWeb.AuthController do
  use ExauthWeb, :controller
  import Ecto.Query, warn: false
  import Plug.Conn
  alias Exauth.Accounts
  alias ExauthWeb.Utils
  alias Exauth.Accounts.User
  alias ExauthWeb.JWTToken
  alias Exauth.AuthTokens.AuthToken
  alias Exauth.Repo

  @spec ping(Plug.Conn.t(), any) :: Plug.Conn.t()
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

  def login(conn, %{"username" => username, "password" => password}) do
    with %User{} = user <- Accounts.get_user_by_username(username),
         true <- Pbkdf2.verify_pass(password, user.password) do
      signer =
        Joken.Signer.create(
          "HS256",
          "zrhYVRfAP4uNwYVPxrngiqhrlJhB/Wd2REcf9W870RL2O+Mq/bfVVZl0rJWT2WFz"
        )

      extra_claims = %{user_id: user.id}
      {:ok, token, _claims} = JWTToken.generate_and_sign(extra_claims, signer)

      conn |> render("login.json", %{success: true, message: "Login Successful", token: token})
    else
      _ -> conn |> render("error.json", %{error: Utils.invalid_credentials()})
    end
  end

  def get(conn, _params) do
    conn |> render("data.json", %{data: conn.assigns.current_user})
  end

  def delete(conn, _params) do
    case Ecto.build_assoc(conn.assigns.current_user, :auth_tokens, %{token: get_token(conn)})
    |> Repo.insert!() do
      %AuthToken{} ->  conn |> render("ack.json", %{success: true, message: "Logged Out"})
      _ -> conn |> render("error.json", %{error: Utils.internal_server_error()})
    end
  end

  defp get_token(conn) do
    bearer = get_req_header(conn, "authorization") |> List.first()
    if bearer == nil do
      ""
    else
      bearer |> String.split(" ") |> List.last()
    end
  end
end
