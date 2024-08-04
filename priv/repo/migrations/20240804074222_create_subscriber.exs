defmodule PingMe.Repo.Migrations.CreateSubscriber do
  use Ecto.Migration

  def change do
    create table(:subscriber) do
      add :subscription_data, :string

      timestamps(type: :utc_datetime)
    end
  end
end
