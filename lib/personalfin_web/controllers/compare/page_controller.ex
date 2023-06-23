defmodule PersonalfinWeb.Compare.PageController do
  use PersonalfinWeb, :controller

  alias Personalfin.Compare
  alias Personalfin.Management

  def index(conn, _params) do
    investments = [
      %{
        name: "OK Smart ETF Exclusive",
        invested: Compare.ok_smart() |> Keyword.values() |> Enum.reduce(fn i, acc -> i + acc end),
        actual_value: Management.get_investment_by_name!("OK Smart ETF Exclusive").value,
        market_value: apply_market_growth(Compare.ok_smart())
      },
      %{
        name: "Active Invest",
        invested:
          Compare.active_invest() |> Keyword.values() |> Enum.reduce(fn i, acc -> i + acc end),
        actual_value: Management.get_investment_by_name!("Active Invest").value,
        market_value: apply_market_growth(Compare.active_invest())
      },
      %{
        name: "Real estate fund - Investika",
        invested:
          Compare.investika() |> Keyword.values() |> Enum.reduce(fn i, acc -> i + acc end),
        actual_value: Management.get_investment_by_name!("Real estate fund").value,
        market_value: apply_market_growth(Compare.investika())
      }
    ]

    render(conn, "index.html",
      investments: investments |> Enum.map(&enrich/1),
      total: total(investments) |> enrich
    )
  end

  def apply_market_growth(investment_deposits) do
    Compare.s_and_p_returns()
    |> Enum.reduce(0, fn {month, interest}, acc ->
      acc * (1 + interest / 100) + Keyword.get(investment_deposits, month, 0)
    end)
  end

  def total(investments) do
    %{
      name: "Total",
      invested: investments |> Enum.reduce(0, fn %{invested: i}, acc -> acc + i end),
      actual_value: investments |> Enum.reduce(0, fn %{actual_value: i}, acc -> acc + i end),
      market_value: investments |> Enum.reduce(0, fn %{market_value: i}, acc -> acc + i end)
    }
  end

  def enrich(investment) do
    investment
    |> Map.put(:actual_change, (investment[:actual_value] / investment[:invested] - 1) * 100)
    |> Map.put(:market_change, (investment[:market_value] / investment[:invested] - 1) * 100)
    |> Map.put(:loss_gain, investment[:actual_value] - investment[:market_value])
  end
end
