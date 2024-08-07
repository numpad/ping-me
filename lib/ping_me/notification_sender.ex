defmodule PingMe.NotificationSender do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{silent: true}, opts)
  end

  def send_ping(pid, subscription, message) do
    GenServer.call(pid, {:send_ping, subscription, message})
  end

  def set_silent(pid, silent) do
    GenServer.call(pid, {:set_silent, silent})
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:send_ping, subscription, message}, _from, state) do
    silent = Map.get(state, :silent, true)
    notification = %PingMe.Notification{message: message, silent: silent}
    {:ok, json} = Jason.encode(notification)
    WebPushElixir.send_notification(subscription, json)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:set_silent, silent}, _from, state) do
    new_state = Map.put(state, :silent, silent)
    {:reply, :ok, new_state}
  end

end

