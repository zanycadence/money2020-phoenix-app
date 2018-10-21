defmodule Money2020Web.BotController do
    use Money2020Web, :controller
    alias Money2020.VisaHelper
    alias Money2020.TwilioHelper
    alias Money2020.Messenger

    @help_message_1 """
      Use one of the available commands
      listed below and replace the place holders
      with your information
      """

    @help_message_2 """
      pay
      to: {recipient nickname}
      amount: {in us dollars}

      register
      full name: {}
      card number: {}
      """

    def webhook_post(conn, %{"entry" => entries, "object" => object} = params) do
      case object do
        "page" ->
          {message, sender_id} =
            entries
            |> Enum.map(fn e -> e |> Messenger.extract_messages() end)
            |> hd

            on_messenger(conn, %{ "Body" => message, "From" => sender_id })
      end

  end

    def on_messenger(conn, assigns) do
        dispatch conn, assigns, :messenger
    end

    def on_sms(conn, assigns) do
        dispatch conn, assigns, :sms
    end

    def parse_body(body) do
        body = String.replace(body, "\n", " ")
        case String.split(body) do
            ["menu" | _rest ] ->
                { :help, [] }
            ["register" | _rest ] -> 
                IO.inspect body
                { :register, Regex.run(~r/(.*)full name:(?<to>.*)card number:(?<card>.*)/, body, capture: :all_names) }
            ["pay" | _rest ] ->
                { :pay, Regex.run(~r/(.*)to:(?<to>.*)amount:(?<amount>.*)/, body, capture: :all_names) }
            [] ->
                :error
        end
    end

    defp dispatch(conn, input, bot) do
        body = Map.get(input, "Body")
        user_id = case bot do
          :sms -> Map.get(input, "From") |> String.slice(1..-1)
          :messenger -> Map.get(input, "From")
        end
        conn = assign(conn, :user_id, user_id)
        
        case parse_body(body) do
            { _any, nil } ->
                bot_message(conn, "format error", bot)
            { :help, assigns } ->
                bot_message(conn, @help_message_1, bot)
                bot_message(conn, @help_message_2, bot)
            { :register, assigns } ->
                [name, card_number] = assigns
                bot_message(conn, "Your registration request is being processed", bot)
                register conn, name, card_number, bot
            { :pay, assigns } ->
                [to, amount] = assigns
                bot_message(conn, "your payment is being processed", bot)
                pay conn, to, amount, bot
        end

        conn
          |> assign(:response, "cool")
          |> render("status.html")
    end

    defp register(conn, name, card_number, bot) do
        case VisaHelper.register(conn.assigns.user_id) do
            { :ok, %{ body: [message: message, reason: reason]}} ->
                bot_message(conn, String.slice(message, 9..-1), bot)
            { :ok, %{ body: body } } ->
                IO.inspect body
                bot_message(conn, "Your registration was completed successfully, use your phone number/email to recieve payments from others!", bot)
            error ->
                IO.inspect error
        end
        conn
    end

    defp pay(conn, to, amount, bot) do
        case VisaHelper.pay(conn.assigns.user_id, to, amount) do
            { :ok, %{ body: %{message: message, reason: reason}}} ->
                bot_render conn, "status", %{message: String.slice(message, 9..-1)}, bot
            { :ok, response } ->
                IO.inspect response
                bot_message(conn, "Your payment was completed successfully!", bot)
            error ->
                IO.inspect error
        end
        conn
    end

    defp bot_message(conn, message, bot) do
      case bot do
        :sms -> TwilioHelper.send_sms(conn.assigns.user_id, message)
        :messenger -> Messenger.send_message(conn.assigns.user_id, message)
      end
    end

    defp bot_render(conn, template, assigns, bot) do
      conn
      |> assign(:response, "cool")
      |> render("status.html")
    end
end