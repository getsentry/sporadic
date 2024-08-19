defmodule Sporadic.Repo do
  use Ecto.Repo,
    otp_app: :sporadic,
    adapter: Ecto.Adapters.Postgres
end
