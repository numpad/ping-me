defmodule PingMe.Notification do
  @derive {Jason.Encoder, only: [:message, :title, :silent, :actions]}

  @enforce_keys [:message]
  defstruct [:message, :title, actions: [], silent: true]


  defmodule Action do
    @derive {Jason.Encoder, only: [:action, :text]}

    @enforce_keys [:action, :text]
    defstruct [:action, :text]
  end
end

