defmodule Personalfin.Compare do
  @moduledoc false

  def ok_smart do
    [
      "2021-10": System.get_env("OK_SMART_INITIAL_INVESTMENT") |> String.to_integer()
    ]
  end

  def active_invest do
    ["2016-12": System.get_env("ACTIVE_INVEST_INITIAL_INVESTMENT") |> String.to_integer()]
    |> Keyword.merge(get_contributions("2017", "01", System.get_env("ACTIVE_INVEST_INITIAL_CONTRIBUTION") |> String.to_integer(), "2018", "12"))
    |> Keyword.merge(get_contributions("2021", "10", System.get_env("ACTIVE_INVEST_CURRENT_CONTRIBUTION") |> String.to_integer()))
  end

  def investika do
    ["2016-12": System.get_env("INVESTIKA_INITIAL_INVESTMENT") |> String.to_integer()]
    |> Keyword.merge(get_contributions("2017", "01", System.get_env("INVESTIKA_INITIAL_CONTRIBUTION") |> String.to_integer(), "2018", "12"))
    |> Keyword.merge(get_contributions("2021", "10", System.get_env("INVESTIKA_CURRENT_CONTRIBUTION") |> String.to_integer()))
  end

  @doc """
  Source: https://www.investing.com/indices/us-spx-500-historical-data
  """
  def s_and_p_returns do
    [
      "2017-01": 1.82,
      "2017-02": 1.79,
      "2017-03": 3.72,
      "2017-04": -0.04,
      "2017-05": 0.91,
      "2017-06": 1.16,
      "2017-07": 0.48,
      "2017-08": 1.93,
      "2017-09": 0.05,
      "2017-10": 1.93,
      "2017-11": 2.22,
      "2017-12": 2.81,
      "2018-01": 0.98,
      "2018-02": 5.62,
      "2018-03": -3.89,
      "2018-04": -2.69,
      "2018-05": 0.27,
      "2018-06": 2.16,
      "2018-07": 0.48,
      "2018-08": 3.60,
      "2018-09": 3.03,
      "2018-10": 0.43,
      "2018-11": -6.94,
      "2018-12": 1.79,
      "2019-01": -9.18,
      "2019-02": 7.87,
      "2019-03": 2.97,
      "2019-04": 1.79,
      "2019-05": 3.93,
      "2019-06": -6.58,
      "2019-07": 6.89,
      "2019-08": 1.31,
      "2019-09": -1.81,
      "2019-10": 1.72,
      "2019-11": 2.04,
      "2019-12": 3.40,
      "2020-01": 2.86,
      "2020-02": -0.16,
      "2020-03": -8.41,
      "2020-04": -12.51,
      "2020-05": 12.68,
      "2020-06": 4.53,
      "2020-07": 1.84,
      "2020-08": 5.51,
      "2020-09": 7.01,
      "2020-10": -3.92,
      "2020-11": -2.77,
      "2020-12": 10.75,
      "2021-01": 3.71,
      "2021-02": -1.11,
      "2021-03": 2.61,
      "2021-04": 4.24,
      "2021-05": 5.24,
      "2021-06": 0.55,
      "2021-07": 2.22,
      "2021-08": 2.27,
      "2021-09": 2.90,
      "2021-10": -4.76,
      "2021-11": 6.91,
      "2021-12": -0.83,
      "2022-01": 4.36,
      "2022-02": -5.26,
      "2022-03": -3.14,
      "2022-04": 3.58,
      "2022-05": -8.80,
      "2022-06": 0.01,
      "2022-07": -8.39,
      "2022-08": 9.11,
      "2022-09": -4.24,
      "2022-10": -9.34,
      "2022-11": 7.99,
      "2022-12": 5.38,
      "2023-01": -5.90,
      "2023-02": 6.18
    ]
  end

  defp get_contributions(from_year, from_month, amount, to_year \\ nil, to_month \\ nil) do
    from = NaiveDateTime.from_iso8601!("#{from_year}-#{from_month}-01T00:00:00")

    until =
      if to_year == nil do
        Timex.today() |> Timex.shift(months: -1)
      else
        NaiveDateTime.from_iso8601!("#{to_year}-#{to_month}-01T00:00:00")
      end

    Timex.Interval.new(from: from, until: until, step: [months: 1], right_open: false)
    |> Enum.map(&Timex.format!(&1, "%Y-%m", :strftime))
    |> Enum.map(fn date -> String.to_atom(date) end)
    |> Keyword.from_keys(amount)
  end
end
