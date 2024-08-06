defmodule PingMe.RateLimiter do
  use GenServer

  # Client API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def check_rate(pid, key) do
    GenServer.call(pid, {:check_rate, key})
  end

  def list_state(pid) do
    GenServer.call(pid, {:list_state})
  end


  # Server Callbacks

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:check_rate, key}, _from, state) do
    current_time = System.system_time(:second)
    case Map.get(state, key) do
      nil ->
        new_state = Map.put(state, key, {current_time, 1})
        {:reply, :ok, new_state}
      {last_time, count} ->
        if current_time - last_time >= 60 do
          new_state = Map.put(state, key, {current_time, 1})
          {:reply, :ok, new_state}
        else
          if count >= 60 do
            {:reply, :rate_limited, state}
          else
            new_state = Map.put(state, key, {last_time, count + 1})
            {:reply, :ok, new_state}
          end
        end
    end
  end

  @impl true
  def handle_call({:list_state}, _from, state) do
    {:reply, state, state}
  end

end

