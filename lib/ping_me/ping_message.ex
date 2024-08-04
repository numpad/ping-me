defmodule PingMe.PingMessage do
  use Ecto.Schema
  import Ecto.Changeset

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
end
