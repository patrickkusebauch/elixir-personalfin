defmodule Personalfin.Rates do
  @moduledoc false

  def account_total(accounts) do
    rates = currency_rates()

    accounts
    |> Enum.map(fn account -> Decimal.to_float(account.balance) / rates[account.currency] end)
    |> Enum.reduce(0.0, fn total, acc -> total + acc end)
  end

  def stock_total(stocks) do
    rate = usd_to_czk_rate()

    stocks
    |> Enum.map(&stock_to_value/1)
    |> Enum.map(fn value -> value * rate end)
    |> Enum.reduce(0.0, fn total, acc -> total + acc end)
  end

  def stock_value(stock) do
    if stock == "IUSA.L" do
      rates = currency_rates()
      response =
        ConCache.get_or_store(:api, stock, fn ->
          HTTPoison.get!(
               "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=IUSA.L&apikey=#{System.get_env("ALPHA_VANTAGE_API_KEY")}"
          )
        end)
      response.body
      |> Jason.decode!()
      |> Map.get("Global Quote")
      |> Map.get("05. price")
      |> String.to_float
      |> Kernel./(100)
      |> Kernel./(rates["GBP"])
      |> Kernel.*(rates["USD"])
    else
      response =
        ConCache.get_or_store(:api, stock, fn ->
          HTTPoison.get!(
            "https://api.polygon.io/v2/aggs/ticker/#{stock}/prev?adjusted=true&apiKey=#{System.get_env("STOCKS_API_KEY")}"
          )
        end)

      response.body
      |> Jason.decode!()
      |> Map.get("results")
      |> List.first()
      |> Map.get("c")
    end
  end

  def stock_to_value(stock) do
    stock.amount * stock_value(stock.name)
  end

  defp currency_rates do
    ConCache.get_or_store(:api, :currency_rates, fn ->
      response =
        HTTPoison.get!(
          "https://api.apilayer.com/exchangerates_data/latest?symbols=CZK,USD,GBP,EUR&base=CZK",
          apikey: System.get_env("EXCHANGE_RATE_API_KEY")
        )

      response.body
      |> Jason.decode!()
      |> Map.get("rates")
    end)
  end

  def usd_to_czk_rate do
    ConCache.get_or_store(:api, :usd_to_czk_rate, fn ->
      response =
        HTTPoison.get!(
          "https://api.apilayer.com/exchangerates_data/latest?symbols=CZK&base=USD",
          apikey: System.get_env("EXCHANGE_RATE_API_KEY")
        )

      response.body
      |> Jason.decode!()
      |> Map.get("rates")
      |> Map.get("CZK")
    end)
  end
end
