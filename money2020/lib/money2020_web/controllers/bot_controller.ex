defmodule Money2020Web.BotController do
    use Money2020Web, :controller
    alias Money2020.VisaHelper
    alias Money2020.TwilioHelper
    alias Money2020.Messenger

    # \xF0\x9F\x92\xB3
    @card_emoji_string <<240, 159, 146, 179>>
    @siren_emoji_string <<240, 159, 154, 168>>
    @checkmark_emoji <<226, 156, 133>>
    @bookkeeping <<0xF0, 0x9F, 0x93, 0x91>>
    @processing <<0xE2, 0x8F, 0xB3>>

    @help_message_1 """
        With Locale you can seemlessly pay to participating local businesses and support your community.
        Available commands
        """

    def help_message_2() do 
        
        """
        register
        full name: ##
        card number: #{@card_emoji_string}
        
        pay
        to: {Locale nickname}
        amount: {in us dollars}
        
        local offers
        """
    end

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
        conn = assign(conn, :bot, :messenger)
        dispatch conn, assigns
    end

    def on_sms(conn, assigns) do
        conn = assign(conn, :bot, :sms)
        dispatch conn, assigns
    end

    def parse_body(body) do
        body = String.replace(body, "\n", " ")
        case String.split(body) do
            ["menu" | _rest ] ->
                { :help, [] }
            ["register" | _rest ] -> 
                IO.inspect body
                # { :register, Regex.run(~r/(.*)full name:(?<to>.*)card number:(?<card>.*)/, body, capture: :all_names) }
                :register
            ["pay" | _rest ] ->
                { :pay, Regex.run(~r/(.*)to:(?<to>.*)amount:(?<amount>.*)/, body, capture: :all_names) }
            ["local" | ["offers" | _rest] ] ->
                :local_offers
            [] ->
                :format_error
            [_unknown] ->
                :format_error
        end
    end

    defp dispatch(conn, input) do
        body = Map.get(input, "Body")
        user_id = case conn.assigns.bot do
          :sms -> Map.get(input, "From") |> String.slice(1..-1)
          :messenger -> Map.get(input, "From")
        end
        conn = assign(conn, :user_id, user_id)
        
        case parse_body(body) do
            { _any, nil } ->
                bot_message(conn, @siren_emoji_string <> " Invalid format, the help messages are out!")
                bot_message(conn, @help_message_1)
                bot_message(conn, help_message_2())
            { :help, assigns } ->
                bot_message(conn, @help_message_1)
                bot_message(conn, help_message_2())
            :register ->
                bot_message(conn, ("Register with FastLink: " <> "https://money2020.ngrok.io/register?from=" <> conn.assigns.user_id))
                # [user_id] = assigns 
                # bot_message(conn, @processing <> " Your registration request is being processed")
                # register conn, name, card_number
            { :pay, assigns } ->
                [to, amount] = assigns
                bot_message(conn, @processing <> " Your payment is being processed")
                pay conn, to, amount
            :local_offers ->
                %{category: category, image_url: image_url, program: program, title: title } =
                    VisaHelper.offers()
                bot_message(conn, image_url)
                case conn.assigns.bot do
                    :messenger ->
                        Messenger.send_image(conn.assigns.user_id, program, (category <> " " <> title), image_url)
                    :sms ->
                        offer_message = 
                            """
                            #{title}
                            #{category}
                            program - local business support
                            """
                        bot_message(conn, offer_message)
                end
            :format_error ->
                bot_message(conn, @siren_emoji_string <> " Invalid format, help is on the way")
                bot_message(conn, @help_message_1)
                bot_message(conn, help_message_2())
        end

        conn
          |> render("status.html")
    end

    defp register(conn, name, card_number) do
        { user_id, alias_type } = 
            if conn.assigns.bot == :sms do
                { conn.assigns.user_id, "01" }
            else
                { random_string(15) <> "@gmail.com", "02" }
            end
        case VisaHelper.register(user_id, alias_type) do
            %{ body: body, status_code: 400 } ->
                message = Enum.filter(body, 
                    fn { k, v } ->
                        :message == k
                    end) |> List.first |> (fn {_, v} -> v end).()
                bot_message(conn, String.slice(message, 9..-1))
            %{ body: body } ->
                bot_message(conn, @checkmark_emoji <> "Your registration was completed successfully, use your phone number/email to recieve payments from others!")
            error ->
                IO.inspect error
        end
        conn
    end

    defp pay(conn, to, amount) do
        { user_id, alias_type } = 
            if conn.assigns.bot == :sms do
                { conn.assigns.user_id, "01" }
            else
                { random_string(15) <> "@gmail.com", "02" }
            end
        case VisaHelper.pay(user_id, to, amount) do
            %{ body: body, status_code: 400 } ->
                message = Enum.filter(body, 
                    fn { k, v } ->
                        :message == k
                    end) |> List.first |> (fn {_, v} -> v end).()
                bot_message(conn, String.slice(message, 9..-1))
            %{ body: body } ->
                IO.inspect body
                id = Enum.filter(body, 
                    fn { k, v } ->
                        :transactionIdentifier == k
                    end) |> List.first |> (fn {_, v} -> v end).() |> to_string()
                bot_message(conn,  @checkmark_emoji <> "Your payment was completed successfully, transaction id: " <> id <> @bookkeeping)
            error ->
                IO.inspect error
        end
        conn
    end

    defp bot_message(conn, message) do
      case conn.assigns.bot do
        :sms -> TwilioHelper.send_sms(conn.assigns.user_id, message)
        :messenger -> Messenger.send_message(conn.assigns.user_id, message)
      end
    end

    def random_string(length) do
        :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
    end
end