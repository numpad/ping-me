defmodule PingMeWeb.PageController do
  use PingMeWeb, :controller

  alias PingMe.Repo
  alias PingMe.{PingMessage, Subscriber}
  alias PingMeWeb.Utils.ConnUtils

  def sender(conn, _params) do
    render(conn, :sender)
  end

  def ping(conn, params) do
    ip = ConnUtils.get_client_ip(conn)
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


end

