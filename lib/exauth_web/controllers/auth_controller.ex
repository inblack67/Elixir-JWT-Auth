defmodule ExauthWeb.AuthController do
  use ExauthWeb, :controller

  def ping(conn, _params) do
    conn
    |> render("ack.json", %{success: true, message: "Pong"})
  end

end
