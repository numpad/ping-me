defmodule PingMe.PingMessage do
  use Ecto.Schema
  import Ecto.{Changeset, Query}

  alias PingMe.Repo

  schema "ping_messages" do
    field :message, :string
    field :ip, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(ping_message, attrs) do
    ping_message
    |> cast(attrs, [:message, :ip])
    |> validate_required([:message])
    |> validate_length(:message, max: 256)
  end

  def get_latest() do
    Repo.all(
      from msg in __MODULE__,
        limit: 25,
        order_by: [desc: msg.inserted_at])
  end

  def get_latest_from_ip(ip) do
    Repo.all(
      from msg in __MODULE__,
        limit: 25,
        where: msg.ip == ^ip,
        order_by: [desc: msg.inserted_at])
  end

end
