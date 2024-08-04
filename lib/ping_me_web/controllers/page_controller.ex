defmodule PingMeWeb.PageController do
  use PingMeWeb, :controller

  import Ecto.Query

  alias PingMe.Repo
  alias PingMe.{PingMessage, Subscriber}

  def home(conn, _params) do
    render(conn, :home)
  end

  def ping(conn, params) do
    ip = ip_to_string(conn.remote_ip)
    changeset = PingMessage.changeset(%PingMessage{ip: ip}, params)

    if changeset.valid? do
      {:ok, _} = Repo.insert(changeset)

      send_sub = fn sub ->
        WebPushElixir.send_notification(sub.subscription_data, "#{params["message"]}")
      end

      Repo.all(Subscriber)
        |> Enum.map(send_sub)

      redirect(conn, to: ~p"/")
    else
      conn
      |> assign(:message_error, "Can't be blank")
      |> render(:home)
    end
  end

  def subscribe(conn, %{ "subscription" => subscription_data }) do
    changeset = Subscriber.changeset(%Subscriber{}, %{ subscription_data: subscription_data })
    {:ok, _} = Repo.insert(changeset)

    WebPushElixir.send_notification(
      subscription_data,
      "You are subscribed! This is how you'll receive notifications.")

    redirect(conn, to: ~p"/")
  end

  def receiver(conn, _params) do
    msgs = Repo.all(
      from msg in PingMessage,
        limit: 100,
        order_by: [desc: msg.inserted_at])

    conn
      |> assign(:ping_messages, msgs)
      |> render(:receiver, layout: false)
  end


  defp ip_to_string(remote_ip) do
    {a, b, c, d} = remote_ip
    "#{a}.#{b}.#{c}.#{d}"
  end

end

