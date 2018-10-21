defmodule Money2020.Yodlee do
  defp cobrand_login do
    "sbCobd45f4de596b1f03301bc53114f46e9b2da"
  end

  defp cobrand_pw do
    "e5f2dccd-e11b-4348-9cc7-cc1dc1951291"
  end

  defp yodlee_endpoint do
    "https://developer.api.yodlee.com/ysl/"
  end

  def get_cobrand_session() do
    headers = [
      {"Content-Type", "application/json"},
      {"Api-Version", "1.1"},
      {"Cobrand-name", "restserver"}
    ]

    cobrand = %{"cobrandLogin" => cobrand_login(), "cobrandPassword" => cobrand_pw()}
    request_body = %{cobrand: cobrand}
    encoded_req_body = Poison.encode!(request_body)

    yodlee_response =
      HTTPoison.post!(
        yodlee_endpoint() <> "/cobrand/login",
        encoded_req_body,
        headers
      )

    yodlee_response.body |> Poison.decode!() |> Map.get("session") |> Map.get("cobSession")
  end

  def get_user_session(cobrand_session) do
    headers = [
      {"Content-Type", "application/json"},
      {"Api-Version", "1.1"},
      {"Authorization", "cobSession=" <> cobrand_session},
      {"Cobrand-name", "restserver"}
    ]

    user = %{
      "loginName" => "sbMemd45f4de596b1f03301bc53114f46e9b2da2",
      "password" => "sbMemd45f4de596b1f03301bc53114f46e9b2da2#123",
      "locale" => "en_US"
    }

    request_body = %{user: user}
    encoded_req_body = Poison.encode!(request_body)

    yodlee_response =
      HTTPoison.post!(
        yodlee_endpoint() <> "/user/login",
        encoded_req_body,
        headers
      )

    yodlee_response.body
    |> Poison.decode!()
    |> Map.get("user")
    |> Map.get("session")
    |> Map.get("userSession")
  end

  def get_fast_link_token(cobrand_session, user_session) do
    headers = [
      {"Content-Type", "application/json"},
      {"Api-Version", "1.1"},
      {"Authorization", "cobSession=" <> cobrand_session <> ",userSession=" <> user_session},
      {"Cobrand-name", "restserver"}
    ]

    request_body = %{}
    encoded_req_body = Poison.encode!(request_body)

    yodlee_response =
      HTTPoison.get!(
        yodlee_endpoint() <> "/user/accessTokens?appIds=10003600",
        headers
      )

    yodlee_response.body
    |> Poison.decode!()
    |> Map.get("user")
    |> Map.get("accessTokens")
    |> hd
    |> Map.get("value")
    |> IO.inspect()
  end

  def get_transaction_data(cobrand_session, user_session) do
    headers = [
      {"Content-Type", "application/json"},
      {"Api-Version", "1.1"},
      {"Authorization", "cobSession=" <> cobrand_session <> ",userSession=" <> user_session},
      {"Cobrand-name", "restserver"}
    ]

    request_body = %{}
    encoded_req_body = Poison.encode!(request_body)

    yodlee_response =
      HTTPoison.get!(
        yodlee_endpoint() <> "/transactions",
        headers
      )

    yodlee_response.body
    |> Poison.decode!()
  end
end
