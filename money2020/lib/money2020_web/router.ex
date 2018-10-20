defmodule Money2020Web.Router do
  use Money2020Web, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    # plug(:protect_from_forgery) it's a hackathon
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", Money2020Web do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/webhook", MessengerController, :webhook)
    post("/webhook", MessengerController, :webhook_post)
  end

  scope "/api", Money2020Web do
    pipe_through(:api)
  end
end
