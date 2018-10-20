defmodule Money2020.VisaHelper do
    alias Money2020.VisaApiClient
    
    def create(user_id) do
        body = %{
            "guid" => user_id,
            "recipientFirstName" => "Jamie",
            "recipientMiddleName" => "M",
            "recipientLastName" => "Bakari",
            "address1" => "Street 1",
            "address2" => "Region 1",
            "city" => "Nairobi",
            "country" => "KE",
            "postalCode" => "00111",
            "consentDateTime" => "2018-03-01 01:02:03",
            "recipientPrimaryAccountNumber" => "4895140000066666",
            "issuerName" => "Test Bank 1",
            "cardType" => "Visa Classic",
            "alias" => "254711333888",
            "aliasType" => "01"
        }
        case VisaApiClient.post("/visaaliasdirectory/v1/manage/createalias", (Poison.encode! body)) do
            { :ok, response } -> response.body
            error -> IO.inspect error
        end
    end

    def resolve(user_alias) do
        body = %{
            "alias" => user_alias,
            "businessApplicationId" => "PP"
        }
        case VisaApiClient.post("/visaaliasdirectory/v1/resolve", (Poison.encode! body)) do
            { :ok, response } -> response.body
            error -> IO.inspect error
        end
    end
end