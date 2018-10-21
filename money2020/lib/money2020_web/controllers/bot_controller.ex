defmodule Money2020Web.BotController do
    use Money2020Web, :controller
    alias Money2020.VisaHelper
    alias Money2020.TwilioHelper

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
        body = 
            case bot do
                :sms -> Map.get(input, "Body")
                :messenger -> Map.get(input, "body")
            end
        case parse_body(body) do
            { _any, nil } ->
                bot_render conn, "format_error", %{}, bot
            { :help, assigns } ->
                bot_render conn, "help", %{}, bot
            { :register, assigns } ->
                [name, card_number] = assigns
                conn = bot_render conn, "status", %{ message: "your registration request is being processed " }, bot
                register conn, name, card_number, bot
            { :pay, assigns } ->
                [to, amount] = assigns
                conn = bot_render conn, "status", %{ message: "your payment is being processed " }, bot
                pay conn, to, amount, bot
        end
    end

    defp register(conn, name, card_number, bot) do
        case VisaHelper.register(conn.assigns.user_id) do
            { :ok, %{ body: [message: message, reason: reason]}} ->
                IO.puts "failure occured"
                IO.puts message
                TwilioHelper.send_sms(conn.assigns.user_id, String.slice(message, 9..-1))
            { :ok, %{ body: body } } ->
                IO.inspect body
                case bot do
                    :sms -> TwilioHelper.send_sms(conn.assigns.user_id, "Your registration was completed successfully, use your phone number to recieve payments from others!")
                    :messenger -> MessengerHelper.send_message(conn.assigns.user_id, "Your registration was completed successfully, use your email registered with facebook to recieve payments from others!")
                end
            error ->
                IO.puts "loool"
                IO.inspect error
        end
        conn
    end

    defp pay(conn, to, amount, bot) do
        case VisaHelper.pay(conn.assigns.user_id, to, amount) do
            { :ok, %{ body: %{message: message, reason: reason}}} ->
                IO.puts "failure occured"
                IO.puts message
                bot_render conn, "status", %{message: String.slice(message, 9..-1)}, bot
            { :ok, response } ->
                IO.inspect response
                case bot do
                    :sms -> TwilioHelper.send_sms(conn.assigns.user_id, "Your payment was completed successfully!")
                    :messenger -> MessengerHelper.send_message(conn.assigns.user_id, "Your payment was completed successfully!")
                end
            error ->
                IO.puts "loool"
                IO.inspect error
        end
        conn
    end

    defp bot_render(conn, template, assigns, bot) do
        format = 
            case bot do
                :sms -> ".xml"
                :messenger -> ".json"
            end
        render conn, (template <> format), assigns
    end
end