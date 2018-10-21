defmodule Money2020Web.Router do
  use Money2020Web, :router

  pipeline :browser do
    plug(:accepts, ["html", "json"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", Money2020Web do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)

    get("/webhook", BotController, :webhook)
    post("/webhook", BotController, :webhook_post)
    post("/bots/sms", BotController, :on_sms)
    get("/register", YodleeController, :yodlee_auth)
    get("/summary", YodleeController, :summary)
    get("/account_success", YodleeController, :account_success)
    get("/account_summary", YodleeController, :account_summary)
  end

  scope "/api", Money2020Web do
    pipe_through(:api)
    get("/summary_results", YodleeController, :summary_results)
  end
end
