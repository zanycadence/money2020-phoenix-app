defmodule Money2020Web.MessengerController do
  use Money2020Web, :controller

  def webhook(conn, %{
        "hub.challenge" => hub_challenge
        # "hub.mode" => mode,
        # "hub.verify_token" => verify_token
      }) do
    conn
    |> assign(:response, hub_challenge)
    |> render("webhook.html")
  end

  def webhook_post(conn, params) do
    params |> IO.inspect()

    conn
    |> assign(:response, "EVENT_RECEIVED")
    |> render("webhook.html")
  end
end
