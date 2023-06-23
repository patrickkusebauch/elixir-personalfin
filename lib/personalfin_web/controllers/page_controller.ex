defmodule PersonalfinWeb.PageController do
  use PersonalfinWeb, :controller

  alias Personalfin.Projection
  alias Personalfin.Repo
  alias PersonalfinWeb.Management
  import Ecto.Query, warn: false

  def index(conn, _params) do
    {management, _, _} = Management.PageController.get_overview_data()

    transactions =
      Personalfin.Transaction
      |> select([i], [fragment("to_char(?, 'YYYY-MM') AS month", i.date), sum(i.amount)])
      |> where([i], i.amount > 0)
      |> group_by([i], fragment("month"))
      |> order_by(desc: fragment("month"))
      |> limit(15)
      |> Repo.all()

    expenses = Personalfin.Management.list_categories()

    {projection, target, month} =
      expenses
      # monthly expenses
      |> Enum.reduce(0.0, fn category, acc -> acc + category.budget end)
      # yearly expenses
      |> Kernel.*(12)
      # percentage that can be sold every year
      |> Kernel./(0.04)
      |> Projection.get_projection_until()

    data = [
      %{name: "Accounts", data: Projection.sum_projection(projection[:accounts])},
      %{name: "Investments", data: Projection.sum_projection(projection[:investments])},
      %{name: "Stocks", data: Projection.sum_projection(projection[:stocks])}
    ]

    total = Projection.sum_projection(data)
    data = data ++ [%{name: "Total", data: total}]

    render(conn, "index.html",
      management: Jason.encode!(management),
      projection: Jason.encode!(data),
      transactions: Jason.encode!(transactions),
      expenses: expenses,
      target: target,
      month: month
    )
  end
end
