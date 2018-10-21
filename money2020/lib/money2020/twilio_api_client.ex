defmodule Money2020.TwilioApiClient do
    use HTTPoison.Base

    def process_request_url(url) do
        "https://api.twilio.com/2010-04-01/Accounts/ACd196c471815f0b3aa1163df434c1056e/Messages.json" <> url
    end

    def process_request_headers(headers) do
        [ { "Authorization", "Basic QUNkMTk2YzQ3MTgxNWYwYjNhYTExNjNkZjQzNGMxMDU2ZTo5NWE1YjQyYTc4MzU3MzRlYmYxM2U4NjViNmY1MjQ1OQ=="} 
        | headers ]
    end

    def process_response_body(body) do
        body
        |> Poison.decode!
        |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
    end
end