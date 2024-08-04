defmodule PingMe.Subscriber do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subscriber" do
    field :subscription_data, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(subscriber, attrs) do
    subscriber
    |> cast(attrs, [:subscription_data])
    |> validate_required([:subscription_data])
  end
end
