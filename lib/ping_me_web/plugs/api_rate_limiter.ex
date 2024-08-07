defmodule PingMeWeb.Plugs.ApiRateLimiter do
  import Plug.Conn

  alias PingMe.RateLimiter
  alias PingMeWeb.Utils.ConnUtils

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    ip = ConnUtils.get_client_ip(conn)

    case RateLimiter.check_rate(RateLimiter, ip) do
      :ok ->
        conn
      :rate_limited ->
        conn
          |> put_status(:too_many_requests)
          |> Phoenix.Controller.json(%{error: "Rate limit exceeded"})
          |> halt()
    end
  end

end

