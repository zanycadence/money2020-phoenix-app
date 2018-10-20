defmodule Money2020.Messenger do
  defmodule Entry do
    defstruct [:id, :time]
  end

  defmodule Messaging do
    defstruct [:message, :recipient, :sender, :timestamp]
  end

  defmodule Message do
    defstruct [:mid, :seq, :text]
  end

  defmodule Recipient do
    defstruct [:id]
  end

  defmodule Sender do
    defstruct [:id]
  end

  defp get_messaging(entry) do
    entry
    |> Map.get("messaging")
  end

  defp get_recipient(messaging) do
    recipient =
      messaging
      |> Map.get("recipient")

    id =
      recipient
      |> Map.get("id")

    %Recipient{id: id}
  end

  defp get_sender(messaging) do
    sender =
      messaging
      |> Map.get("sender")

    id =
      sender
      |> Map.get("id")

    %Sender{id: id}
  end

  defp get_message(messaging) do
    top =
      messaging
      |> Map.get("message")

    mid =
      top
      |> Map.get("mid")

    seq =
      top
      |> Map.get("seq")

    text =
      top
      |> Map.get("text")

    %Message{mid: mid, seq: seq, text: text}
  end

  def extract_messages(entry) do
    messaging =
      entry
      |> get_messaging()
      |> hd

    message =
      messaging
      |> get_message
      |> hd

    recipient =
      messaging
      |> Enum.map(fn m -> m |> get_recipient end)
      |> hd

    sender =
      messaging
      |> Enum.map(fn m -> m |> get_sender end)
      |> hd

    sender.id |> IO.inspect()
    recipient = %{"id" => sender.id}

    params = %{
      access_token:
        "EAAfBV7upiPsBALJHqTOo9nNAvDQHZAMBobxZCEOjgbR7ULEqPP24vZBDtzi3TubuNMUHxLx6LmakdxO6fCb2YOYhMh749gFWjG4cAK5hLHhbM7fw1BKtsCcRmzuzHbdqcrnYn7T9zeccZBj7kxPTeDZClIs8cmyZA8E9uEZBZBcOxQZDZD"
    }

    response_message = %{"text" => "test response"}
    request_body = %{"recipient" => recipient, "message" => response_message}
    encoded_req_body = Poison.encode!(request_body)

    HTTPoison.post!(
      "https://graph.facebook.com/v2.6/me/messages",
      encoded_req_body,
      [{"Content-Type", "application/json"}],
      params: params
    )
  end
end
