defmodule Money2020.VisaApiClient do
    use HTTPoison.Base

    def process_request_url(url) do
        "https://sandbox.api.visa.com" <> url
    end

    def process_request_options(options) do
        ssl = [
            certfile: "./cert.pem",
            keyfile: "./key.pem",
            password: String.to_char_list(""),
            versions: [:'tlsv1.2']
        ]
        [ {:ssl, ssl} | options ]
    end

    def process_request_headers(headers) do
        [ { "Authorization", "Basic Tk9GT0lVNU5NMTlMR0hXRjhVSEIyMTdtSGtFbjh4OW16aHBOaldVeU04NHFYN3ZkMDoyTFVPQjJPRGQ5QnBVN2NTSjZSODlOQ2U3"} 
        | [ {"Content-Type", "application/json"}
        | headers ] ]
    end

    def process_response_body(body) do
        body
        |> Poison.decode!
        |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
    end
end