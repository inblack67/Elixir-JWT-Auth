defmodule ExauthWeb.AuthView do
  use ExauthWeb, :view

  def render("ack.json", %{success: success, message: message}), do: %{success: success, message: message}
end
