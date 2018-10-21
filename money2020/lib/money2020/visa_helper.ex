defmodule Money2020.VisaHelper do
  alias Money2020.VisaApiClient

    def random_string(length) do
        :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
    end

    def register(user_alias, alias_type) do
        body = %{
            "guid" => ("574f4b6a4c2b70472f306f300099515a789092348832455975343637a4" <> random_string(5)), #3170
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
            "alias" => user_alias,
            "aliasType" => alias_type
        }
        VisaApiClient.post!("/visaaliasdirectory/v1/manage/createalias", (Poison.encode! body))
    end

    def resolve(user_alias) do
        body = %{
            "alias" => user_alias,
            "businessApplicationId" => "PP"
        }
        VisaApiClient.post!("/visaaliasdirectory/v1/resolve", (Poison.encode! body))
    end

    def pay(user_alias, to, amount) do
        body = %{
            "acquirerCountryCode" => "840",
            "acquiringBin" => "408999",
            "amount" => "124.02",
            "businessApplicationId" => "AA",
            "cardAcceptor" => %{
                "address" => %{
                    "country" => "USA",
                    "county" => "081",
                    "state" => "CA",
                    "zipCode" => "94404"
                },
                "idCode" => "ABCD1234ABCD123",
                "name" => "Visa Inc. USA-Foster",
                "terminalId" => "ABCD1234"
            },
            "cavv" => "0700100038238906000013405823891061668252",
            "foreignExchangeFeeTransaction" => "11.99",
            "localTransactionDateTime" => "2018-10-21T05:01:06",
            "retrievalReferenceNumber" => "330000550000",
            "senderCardExpiryDate" => "2015-10",
            "senderCurrencyCode" => "USD",
            "senderPrimaryAccountNumber" => "4895142232120006",
            "surcharge" => "11.99",
            "systemsTraceAuditNumber" => "451001",
            "nationalReimbursementFee" => "11.22",
            "cpsAuthorizationCharacteristicsIndicator" => "Y",
            "addressVerificationData" => %{
                "street" => "XYZ St",
                "postalCode" => "12345"
            }
        } |> Poison.encode!()

        VisaApiClient.post!("/visadirect/fundstransfer/v1/pullfundstransactions", body)
    end

    def offers() do
      params = %{
        "business_segment" => "39", # small business
      }

      keys = [
        "imageList", "programName",
        "shareTitle", "businessSegmentList",
        "offerContentId", "categorySubcategoryList"
      ]

      response = VisaApiClient.get!("/vmorc/offers/v1/byfilter", [], params: params)
      %{
        "categorySubcategoryList" => [ (%{"value" => category }) | _rest ],
        "imageList" => image_list,
        "programName" => program,
        "shareTitle" => title 
      } =
      response.body
        |> List.first()
        |> (fn { _, offers } -> offers end).()
        |> List.first()
        |> Map.take(keys)
    
      [%{"fileLocation" => image_url} | _rest ] = image_list
      %{category: category, image_url: image_url, program: program, title: title }
    end
end
