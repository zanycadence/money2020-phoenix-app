defmodule Money2020.VisaHelper do
  alias Money2020.VisaApiClient

  def register(user_alias) do
    body = %{
      "guid" => "574f4b6a4c2b70472f306f300099515a789092348832455975343637a4d3170",
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
      "aliasType" => "01"
    }

    VisaApiClient.post("/visaaliasdirectory/v1/manage/createalias", Poison.encode!(body))
  end

  def resolve(user_alias) do
    body = %{
      "alias" => user_alias,
      "businessApplicationId" => "PP"
    }

    VisaApiClient.post!("/visaaliasdirectory/v1/resolve", Poison.encode!(body))
  end

  def pay(user_alias, to, amount) do
    {:ok, "everything ok"}
  end
end
