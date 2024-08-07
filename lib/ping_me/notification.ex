defmodule PingMe.Notification do
  @derive {Jason.Encoder, only: [:message, :title, :silent]}

  @enforce_keys [:message]
  defstruct [:message, :title, silent: true]
end

