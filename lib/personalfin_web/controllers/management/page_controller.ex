defmodule PersonalfinWeb.Management.PageController do
  use PersonalfinWeb, :controller

  alias Personalfin.Management
  alias Personalfin.Rates

  def index(conn, _params) do
    {data, assets, total} = get_overview_data()

    render(conn, "index.html", assets: assets, total: total, data: Jason.encode!(data))
  end

  def get_overview_data do
    assets = %{
      Accounts: Rates.account_total(Management.list_accounts()),
      Investments:
        Management.list_investments()
        |> Enum.reduce(0.0, fn investment, acc -> investment.value + acc end),
      Stocks: Rates.stock_total(Management.list_stocks())
    }

    total =
      assets
      |> Enum.reduce(0.0, fn {_, total}, acc -> total + acc end)

    data =
      assets
      |> Enum.map(fn {name, value} -> [name, value] end)

    {data, assets, total}
  end
end
