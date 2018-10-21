defmodule Money2020Web.YodleeView do
  use Money2020Web, :view

  def render("summary.json", %{transactions: transactions}) do
    %{
      transactions: render_many(transactions, Money2020Web.YodleeView, "transaction.json")
    }
  end

  def render("transaction.json", %{yodlee: transaction}) do
    %{
      category: transaction.category,
      category_type: transaction.category_type,
      amount: transaction.amount
    }
  end
end
