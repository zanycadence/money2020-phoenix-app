defmodule H do
    alias Money2020.VisaApiClient

    # %{ user_id: user_id,
    #     alias_name: alias_name,
    #     first_name: first_name,
    #     last_name: last_name,
    #     country: country,
    #     issuer_name: issuer_name,
    #     card_number: card_number,
    #     card_type: card_type, # like Visa Classic
    #     alias_type: alias_type
    #     }
    def create(user_id) do

        # alias_type = case alias_type do
        #     :phone -> "01"
        #     :email -> "2"
        # end

        # currentTime = DateTime.utc_now() |> DateTime.to_string() |> String.slice(0..-9)
        # body = %{
        #     "guid" => user_id,
        #     "recipientFirstName" => first_name,
        #     "recipientLastName" => last_name,
        #     "country" => country,
        #     "consentDateTime" => "2018-06-02 11:20:00", #currentTime,
        #     "recipientPrimaryAccountNumber" => card_number,
        #     "issuerName" => issuer_name,
        #     "cardType" => card_type,
        #     "alias" => alias_name,
        #     "aliasType" => alias_type
        # }
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
            { :ok, response } -> response
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