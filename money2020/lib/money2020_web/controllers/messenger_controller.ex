defmodule Money2020Web.MessengerController do
  use Money2020Web, :controller
  alias Money2020.Messenger

  def webhook(conn, %{
        "hub.challenge" => hub_challenge
        # "hub.mode" => mode,
        # "hub.verify_token" => verify_token
      }) do
    conn
    |> assign(:response, hub_challenge)
    |> render("webhook.html")
  end

  def webhook_post(conn, %{"entry" => entries, "object" => object} = params) do
    {response_text, status_code} =
      case object do
        "page" ->
          {message, sender_id} =
            entries
            |> Enum.map(fn e -> e |> Messenger.extract_messages() end)
            |> hd

          Messenger.send_message(sender_id, "sample response")

          {"EVENT_RECEIVED", 200}

        _ ->
          {"ERROR", 404}
      end

    conn
    |> assign(:response, response_text)
    |> render("webhook.html")
  end
end
