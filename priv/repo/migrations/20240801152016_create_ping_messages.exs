defmodule PingMe.Repo.Migrations.CreatePingMessages do
  use Ecto.Migration

  def change do
    create table(:ping_messages) do
      add :message, :string
      add :ip, :string

      timestamps(type: :utc_datetime)
    end
  end
end
