defmodule Money2020Web.YodleeView do
  use Money2020Web, :view

  def render("summary.json", %{transactions: transactions}) do
    transactions
  end
end
