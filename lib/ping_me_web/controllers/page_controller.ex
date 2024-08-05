defmodule PingMeWeb.PageController do
  use PingMeWeb, :controller

  alias PingMe.Repo
  alias PingMe.{PingMessage, Subscriber}

  def sender(conn, _params) do
    render(conn, :sender)
  end

  def ping(conn, params) do
    ip = get_conn_ip(conn)
    changeset = PingMessage.changeset(%PingMessage{ip: ip}, params)

    if changeset.valid? do
      {:ok, _} = Repo.insert(changeset)

      # TODO: sending fails for all(?) if Subscriber.subscription contains garbage...
      send_sub = fn sub ->
        WebPushElixir.send_notification(sub.subscription_data, "#{params["message"]}")
      end

      Subscriber
        |> Repo.all()
        |> Enum.map(send_sub)

      conn
        |> redirect(to: ~p"/")
    else
      conn
        |> assign(:message_error, "Can't be blank")
        |> render(:sender)
    end
  end

  def receiver(conn, _params) do
    msgs = PingMessage.get_latest()

    conn
      |> assign(:ping_messages, msgs)
      |> render(:receiver)
  end


  @doc """
    Returns a string representation of the clients remote ip.
    Respects a potential reverse proxy.
  """
  defp get_conn_ip(conn) do
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

