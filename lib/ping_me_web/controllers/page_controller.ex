defmodule PingMeWeb.PageController do
  use PingMeWeb, :controller

  alias PingMe.Repo
  alias PingMe.{PingMessage, Subscriber}

  def home(conn, _params) do
    render(conn, :home)
  end

  def ping(conn, params) do
    ip = get_conn_ip(conn)
    changeset = PingMessage.changeset(%PingMessage{ip: ip}, params)

    if changeset.valid? do
      {:ok, _} = Repo.insert(changeset)

      send_sub = fn sub ->
        WebPushElixir.send_notification(sub.subscription_data, "#{params["message"]}")
      end

      # TODO: sending fails for all(?) if Subscriber.subscription contains garbage...
      Subscriber
        |> Repo.all()
        |> Enum.map(send_sub)

      redirect(conn, to: ~p"/")
    else
      conn
      |> assign(:message_error, "Can't be blank")
      |> render(:home)
    end
  end

  def receiver(conn, _params) do
    msgs = PingMessage.get_latest()

    conn
      |> assign(:ping_messages, msgs)
      |> render(:receiver)
  end

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

