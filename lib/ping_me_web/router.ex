defmodule PingMeWeb.Router do
  use PingMeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug PingMeWeb.Plugs.PageRateLimiter
    plug :fetch_live_flash
    plug :put_root_layout, html: {PingMeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug PingMeWeb.Plugs.ApiRateLimiter
  end

  scope "/", PingMeWeb do
    pipe_through :browser

    get "/", PageController, :sender
    post "/", PageController, :ping

    get "/receiver", PageController, :receiver
  end

  # Other scopes may use custom stacks.
  scope "/api", PingMeWeb do
    pipe_through :api

    post "/subscribe", ApiController, :subscribe
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:ping_me, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PingMeWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
