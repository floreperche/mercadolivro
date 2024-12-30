defmodule Mercadolivro.Repo do
  use Ecto.Repo,
    otp_app: :mercadolivro,
    adapter: Ecto.Adapters.Postgres
end
