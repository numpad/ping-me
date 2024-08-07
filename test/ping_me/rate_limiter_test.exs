defmodule PingMe.RateLimiterTest do
  use ExUnit.Case, async: false

  alias PingMe.RateLimiter

  @alice "192.0.2.0"
  @bob   "192.0.2.1"

  setup do
    {:ok, time: 0, pid: start_supervised!({RateLimiter, time_fn: fn -> 0 end})}
  end


  test "allows requests within rate limit", %{pid: pid} do
    for _ <- 1..60 do
      assert :ok == RateLimiter.check_rate(pid, @alice)
    end
    assert :rate_limited == RateLimiter.check_rate(pid, @alice)
  end


  test "allows multiple separate requests within rate limit", %{pid: pid} do
    for _ <- 1..60 do
      assert :ok == RateLimiter.check_rate(pid, @alice)
      assert :ok == RateLimiter.check_rate(pid, @bob)
    end

    assert :rate_limited == RateLimiter.check_rate(pid, @alice)
    assert :rate_limited == RateLimiter.check_rate(pid, @bob)
  end


  test "rate limit resets after time window" do
    {:ok, time_agent} = Agent.start_link(fn -> 0 end)

    time_fn = fn -> Agent.get(time_agent, & &1) end
    {:ok, pid} = RateLimiter.start_link(time_fn: time_fn)

    for _ <- 1..60 do
      assert :ok == RateLimiter.check_rate(pid, @alice)
    end
    assert :rate_limited == RateLimiter.check_rate(pid, @alice)

    Agent.update(time_agent, fn _ -> 60 end)
    assert :ok == RateLimiter.check_rate(pid, @alice)

    Agent.stop(time_agent)
  end

end

