defmodule Personalfin.Projection do
  @moduledoc false

  use Memoize

  alias Personalfin.Management
  alias Personalfin.Rates

  def get_projection_until(amount) do
    current_month = Timex.today() |> Timex.format!("%Y-%m", :strftime)
    accounts = get_base_accounts(current_month)
    investments = get_base_investments(current_month)
    stocks = get_base_stocks(current_month)
    expand_until(amount, current_month, accounts, investments, stocks)
  end

  def ppp_adjusted(item) do
    item
    |> Enum.sort()
    |> Enum.with_index(fn e, i -> {i, e} end)
    |> Enum.map(fn {index, {date, value}} -> {date, true_value(index) |> Apa.mul(value)} end)
    |> Enum.into(%{})
  end

  def sum_projection(items) do
    items
    |> Enum.map(fn item -> item.data end)
    |> Enum.zip()
    |> Enum.flat_map(fn items ->
      %{
        "#{elem(elem(items, 0), 0)}":
          Enum.reduce(Tuple.to_list(items), 0.0, fn item, acc -> elem(item, 1) + acc end)
      }
    end)
    |> Enum.into(%{})
  end

  defp annual_to_monthly_rate(rate, tax) do
    case {rate, tax} do
      # AirBank Accounts
      {0.0400, 0.15} -> 0.0027901
      # UniCredit Accounts
      {0.0600, 0.15} -> 0.0041538
      # MaxBank Accounts
      {0.0601, 0.15} -> 0.0041703
      # Pension Fund
      {0.0657, 0} -> 0.0053167
      # OK Smart
      {0.0132, 0} -> 0.0010934
      # Real Estate
      {0.0847, 0} -> 0.0067983
      # S&P
      {0.0964, 0} -> 0.0076988
      # Stocks - conservative
      {0.0500, 0} -> 0.0040741
      # PSTG
      {0.1000, 0} -> 0.0079741
    end
  end

  defp investment_rate_and_contribution(investment_name) do
    case investment_name do
      "Pension fund" -> {annual_to_monthly_rate(0.0657, 0), fn _ -> 5_270 end}
      "Active Invest" -> {annual_to_monthly_rate(0.0132, 0), fn _ -> 6_000 end}
      "OK Smart ETF Exclusive" -> {annual_to_monthly_rate(0.0132, 0), fn _ -> 0 end}
      "Real estate fund" -> {annual_to_monthly_rate(0.0847, 0), fn _ -> 4_000 end}
    end
  end

  defp account_rate(account_name) do
    case account_name do
      "UniCredit Savings" -> annual_to_monthly_rate(0.06, 0.15)
      "MaxBanka Savings" -> annual_to_monthly_rate(0.0601, 0.15)
      _ -> annual_to_monthly_rate(0.04, 0.15)
    end
  end

  defp stock_rate_and_contribution(stock_name) do
    case stock_name do
      "PSTG" -> {annual_to_monthly_rate(0.1, 0), &psgt_contributions/1}
      "IUSA.L" -> {annual_to_monthly_rate(0.0964, 0), &s_and_p_contributions/1}
      "VZ" -> {annual_to_monthly_rate(0.05, 0), fn _ -> 0 end}
      "AGNC" -> {annual_to_monthly_rate(0.05, 0), fn _ -> 0 end}
      "MO" -> {annual_to_monthly_rate(0.05, 0), fn _ -> 0 end}
    end
  end

  defp s_and_p_contributions(date) do
    case date |> String.slice(-2..-1) do
      "04" -> System.get_env("S_AND_P_CONTRIBUTIONS_04") |> String.to_integer()
      "09" -> System.get_env("S_AND_P_CONTRIBUTIONS_09") |> String.to_integer()
      _ -> System.get_env("S_AND_P_CONTRIBUTIONS_DEFAULT") |> String.to_integer()
    end
  end

  defp psgt_contributions(date) do
    stock_to_value_ratio = Rates.stock_value("PSTG") * Rates.usd_to_czk_rate()
    case date |> String.slice(-2..-1) do
      "03" -> System.get_env("PSGT_CONTRIBUTIONS_03") |> String.to_integer() |> Kernel.*(stock_to_value_ratio)
      "06" -> System.get_env("PSGT_CONTRIBUTIONS_06") |> String.to_integer() |> Kernel.*(stock_to_value_ratio)
      "09" -> System.get_env("PSGT_CONTRIBUTIONS_09") |> String.to_integer() |> Kernel.*(stock_to_value_ratio)
      "12" -> System.get_env("PSGT_CONTRIBUTIONS_12") |> String.to_integer() |> Kernel.*(stock_to_value_ratio)
      _ -> System.get_env("PSGT_CONTRIBUTIONS_DEFAULT") |> String.to_integer() |> Kernel.*(stock_to_value_ratio)
    end
  end

  defp get_base_stocks(current_month) do
    [
      get_base_stock("PSTG", current_month),
      get_base_stock("IUSA.L", current_month),
      get_base_stock("VZ", current_month),
      get_base_stock("AGNC", current_month),
      get_base_stock("MO", current_month)
    ]
  end

  defp get_base_investments(current_month) do
    [
      #      get_base_investment("Pension fund", current_month), # cannot be withdrawn
      get_base_investment("Active Invest", current_month),
      get_base_investment("OK Smart ETF Exclusive", current_month),
      get_base_investment("Real estate fund", current_month),
    ]
  end

  defp get_base_accounts(current_month) do
    [
      get_base_account("AirBank", current_month),
      get_base_account("AirBank Savings", current_month),
      get_base_account("UniCredit Savings", current_month),
      get_base_account("MaxBanka Savings", current_month),
    ]
  end

  defp get_base_stock(name, current_month) do
    price_per_share = Rates.stock_value(name) * Rates.usd_to_czk_rate()

    initial_amount =
      Management.get_stocks_by_name(name)
      |> Enum.reduce(0.0, fn stock, acc -> stock.amount + acc end)
      |> Kernel.*(price_per_share)

    %{
      name: name,
      data: %{current_month => initial_amount}
    }
  end

  defp expand_stocks_by_one_month(stocks, current_month) do
    stocks
    |> Enum.map(fn stock ->
      {rate, contribution} = stock_rate_and_contribution(stock[:name])
      next_month = next_month(current_month)

      next_value =
        stock[:data][current_month] * (1 + rate) + contribution.(next_month)

      %{
        name: stock[:name],
        data: stock[:data] |> Map.put(next_month, next_value)
      }
    end)
  end

  defp expand_until(total, current_month, accounts, investments, stocks) do
    acc_sum =
      accounts |> Enum.reduce(0.0, fn account, acc -> account[:data][current_month] + acc end)

    inv_sum =
      investments
      |> Enum.reduce(0.0, fn investment, acc -> investment[:data][current_month] + acc end)

    stocks_sum =
      stocks |> Enum.reduce(0.0, fn stock, acc -> stock[:data][current_month] + acc end)

    sum = acc_sum + inv_sum + stocks_sum

    if sum >= total do
      {
        %{
          accounts: accounts,
          investments: investments,
          stocks: stocks
        },
        total,
        current_month
      }
    else
      expand_until(
        total,
        next_month(current_month),
        expand_accounts_by_one_month(accounts, current_month),
        expand_investments_by_one_month(investments, current_month),
        expand_stocks_by_one_month(stocks, current_month)
      )
    end
  end

  defp get_base_investment(name, current_month) do
    investment = Management.get_investment_by_name!(name)

    %{
      name: investment.name,
      data: %{current_month => investment.value}
    }
  end

  defp expand_investments_by_one_month(investments, current_month) do
    investments
    |> Enum.map(fn investment ->
      {rate, contribution} = investment_rate_and_contribution(investment[:name])
      next_month = next_month(current_month)
      next_value = investment[:data][current_month] * (1 + rate) + contribution.(next_month)

      %{
        name: investment[:name],
        data: investment[:data] |> Map.put(next_month, next_value)
      }
    end)
  end

  defp expand_accounts_by_one_month(accounts, current_month) do
    accounts
    |> Enum.map(fn account ->
      next_value = account[:data][current_month] * (1 + account_rate(account[:name]))

      %{
        name: account[:name],
        data: account[:data] |> Map.put(next_month(current_month), next_value)
      }
    end)
  end

  defp get_base_account(name, current_month) do
    account = Management.get_account_by_name(name)

    %{
      name: account.name,
      data: %{current_month => account.balance |> Decimal.to_float()}
    }
  end

  defp next_month(date) do
    year = date |> String.slice(0..3)
    month = date |> String.slice(-2..-1)

    NaiveDateTime.from_iso8601!("#{year}-#{month}-01T00:00:00")
    |> NaiveDateTime.add(40, :day)
    |> Timex.format!("%Y-%m", :strftime)
  end

  defmemo(true_value(0), do: Apa.new("1"))
  defmemo(true_value(n), do: "0.9925" |> Apa.mul(true_value(n - 1)))
end
