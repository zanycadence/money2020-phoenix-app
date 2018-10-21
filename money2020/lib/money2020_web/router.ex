defmodule Money2020Web.Router do
  use Money2020Web, :router

  pipeline :browser do
    plug(:accepts, ["html", "json"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:put_secure_browser_headers)
    plug Money2020.Plugs.Auth, []
  end

  scope "/", Money2020Web do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/webhook", MessengerController, :webhook)
    post("/webhook", MessengerController, :webhook_post)
    post "/bots/sms", BotController, :on_sms
  end
end
