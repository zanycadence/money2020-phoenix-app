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

  def summary(conn, _params) do
    conn
    |> render("summary.html")
  end

  def summary_results(conn, %{"user" => user}) do
    yodlee_user =
      case user do
        "1" -> Yodlee.user_1()
        "2" -> Yodlee.user_2()
      end

    cobrand_session = Yodlee.get_cobrand_session()
    user_session = cobrand_session |> Yodlee.get_user_session(yodlee_user)
    transactions = Yodlee.get_transaction_data(cobrand_session, user_session)

    conn
    |> assign(:transactions, transactions)
    |> render("summary.json")
  end

  def summary_results(conn, %{"user" => user}) do
    yodlee_user =
      case user do
        "1" -> Yodlee.user_1()
        "2" -> Yodlee.user_2()
      end

    cobrand_session = Yodlee.get_cobrand_session()
    user_session = cobrand_session |> Yodlee.get_user_session(yodlee_user)
    transactions = Yodlee.get_transaction_data(cobrand_session, user_session)

    conn
    |> assign(:transactions, transactions)
    |> render("summary.json")
  end

  def summary_results(conn, _params) do
    cobrand_session = Yodlee.get_cobrand_session()
    user_session = cobrand_session |> Yodlee.get_user_session()
    transactions = Yodlee.get_transaction_data(cobrand_session, user_session)

    conn
    |> assign(:transactions, transactions)
    |> render("summary.json")
  end

  def account_success(conn, params) do
    params |> IO.inspect()

    conn
    |> render("account_success.html")
  end

  def account_summary(conn, params) do
    params |> IO.inspect()
    conn
    |> render("account_summary.html")
  end
end
