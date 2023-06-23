defmodule Personalfin.Repo do
  use Ecto.Repo,
    otp_app: :personalfin,
    adapter: Ecto.Adapters.Postgres
end
