defmodule PersonalfinWeb.Projection.PageController do
  use PersonalfinWeb, :controller

  alias Personalfin.Projection

  def index(conn, _params) do
    {projection, _, _} = Projection.get_projection_until(25_000_000)
    accounts_sum = Projection.sum_projection(projection[:accounts])
    investments_sum = Projection.sum_projection(projection[:investments])
    stocks_sum = Projection.sum_projection(projection[:stocks])

    data = [
      %{name: "Accounts", data: accounts_sum},
      %{name: "Investments", data: investments_sum},
      %{name: "Stocks", data: stocks_sum}
    ]

    render(conn, "index.html",
      overview: Jason.encode!(data ++ [%{name: "Total", data: Projection.sum_projection(data)}]),
      accounts: Jason.encode!(projection[:accounts] ++ [%{name: "Total", data: accounts_sum}]),
      investments:
        Jason.encode!(projection[:investments] ++ [%{name: "Total", data: investments_sum}]),
      stocks: Jason.encode!(projection[:stocks] ++ [%{name: "Total", data: stocks_sum}])
    )
  end
end
