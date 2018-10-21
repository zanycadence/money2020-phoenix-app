defmodule Money2020Web.Router do
  use Money2020Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Money2020.Plugs.Auth, []
  end

  scope "/", Money2020Web do
    pipe_through :api # Use the default browser stack

    get "/", PageController, :index
    post "/bots/sms", BotController, :on_sms
  end

  # Other scopes may use custom stacks.
  # scope "/api", Money2020Web do
  #   pipe_through :api
  # end
end
