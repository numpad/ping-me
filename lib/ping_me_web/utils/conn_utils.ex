defmodule PingMeWeb.Utils.ConnUtils do
  import Plug.Conn

  def get_client_ip(conn) do
    forwarded_for =
      conn
      |> get_req_header("x-forwarded-for")

    if length(forwarded_for) > 0 do
      forwarded_for
        |> List.first()
        |> String.split(",")
        |> List.first()
        |> String.trim()
    else
      conn.remote_ip
        |> Tuple.to_list()
        |> List.foldr("", fn a, b -> "#{a}.#{b}" end)
        |> String.slice(0..-2//1)
    end
  end

end

