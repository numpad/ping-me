defmodule PingMe.Repo do
  use Ecto.Repo,
    otp_app: :ping_me,
    adapter: Ecto.Adapters.SQLite3
end
