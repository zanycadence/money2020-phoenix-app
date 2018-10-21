defmodule Money2020Web.Router do
  use Money2020Web, :router

  pipeline :browser do
    plug(:accepts, ["html", "json"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:put_secure_browser_headers)
  end

  scope "/", Money2020Web do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/webhook", BotController, :on_messenger_auth)
    post("/webhook", BotController, :webhook_post)
    post "/bots/sms", BotController, :on_sms
    get("/yodlee_auth", YodleeController, :yodlee_auth)
    get("/account_success", YodleeController, :account_success)
    get("/account_summary", YodleeController, :account_summary)
  end
end
