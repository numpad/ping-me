defmodule PingMeWeb.ApiController do
  use PingMeWeb, :controller

  alias PingMe.Repo
  alias PingMe.Subscriber

  def subscribe(conn, %{ "subscription" => subscription_data }) do
    changeset = Subscriber.changeset(%Subscriber{}, %{ subscription_data: subscription_data })
    {:ok, _} = Repo.insert(changeset)

    PingMe.NotificationSender.send_ping(
      PingMe.NotificationSender,
      subscription_data,
      "You are subscribed! This is how you'll receive notifications.")

    json(conn, %{})
  end

end

