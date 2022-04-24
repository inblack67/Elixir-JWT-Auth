defmodule Exauth.Repo do
  use Ecto.Repo,
    otp_app: :exauth,
    adapter: Ecto.Adapters.Postgres
end
