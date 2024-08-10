defmodule PingMe.NotificationSender do
  use GenServer

  alias PingMe.Notification
  alias PingMe.Notification.Action

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{silent: true}, opts)
  end

  def send_ping(pid, subscription, message) do
    GenServer.cast(pid, {:send_ping, subscription, message})
  end

  def set_silent(pid, silent) do
    GenServer.cast(pid, {:set_silent, silent})
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_cast({:send_ping, subscription, message}, state) do
    silent = Map.get(state, :silent, true)
    notification = %Notification{
      message: message, silent: silent,
      actions: [
        %Action{text: "Mark spam", action: "mark-spam"},
      ],
    }
    {:ok, json} = Jason.encode(notification)
    WebPushElixir.send_notification(subscription, json)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:set_silent, silent}, state) do
    new_state = Map.put(state, :silent, silent)
    {:noreply, new_state}
  end

end

