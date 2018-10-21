defmodule Money2020Web.YodleeController do
  use Money2020Web, :controller
  alias Money2020.Yodlee

  def yodlee_auth(conn, _params) do
    cobrand_session = Yodlee.get_cobrand_session()
    user_session = cobrand_session |> Yodlee.get_user_session()
    access_token = Yodlee.get_fast_link_token(cobrand_session, user_session)

    conn
    |> assign(:user_session, user_session)
    |> assign(:access_token, access_token)
    |> render("account_auth.html")
  end

  def account_success(conn, params) do
    params |> IO.inspect()

    conn
    |> render("account_success.html")
  end
end
