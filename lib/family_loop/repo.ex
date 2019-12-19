defmodule FamilyLoop.Repo do
  use Ecto.Repo,
    otp_app: :family_loop,
    adapter: Ecto.Adapters.Postgres
end
