defmodule Money2020.TwilioHelper do
    alias Money2020.TwilioApiClient

    def send_sms(to, body) do
        case TwilioApiClient.post("", {:form, [To: to, From: "+15406666954", Body: body]}) do
            { :ok, response } ->
                IO.inspect response
                :ok
            error ->
                IO.inspect error
                :error
        end
    end
end