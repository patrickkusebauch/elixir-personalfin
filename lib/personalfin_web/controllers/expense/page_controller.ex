defmodule PersonalfinWeb.Expense.PageController do
  use PersonalfinWeb, :controller

  alias Personalfin.Management
  alias Personalfin.Repo

  def index(conn, _params) do
    category_name = Map.get(_params, "category", "Discretionary")

    twelve_months_ago = Timex.today() |> Timex.shift(months: -11) |> Timex.format!("{YYYY}-{0M}-01")

    monthly_expenses =
      Repo.query!("SELECT to_char(t.date, 'YYYY-MM') AS month, sum(t.amount)*-1, c.name
    FROM transaction AS t
    JOIN transaction_category AS c ON t.transaction_category_id = c.id
    WHERE (t.amount < 0)
    AND (t.transaction_category_id IS NOT NULL)
    AND t.date > '" <> twelve_months_ago <> "'
    GROUP BY month, c.name
    ORDER BY month ASC")
      |> Map.get(:rows)
      |> Enum.group_by(&List.last/1)
      |> Enum.map(fn {cat, arr} ->
        %{
          name: cat,
          data:
            Enum.map(arr, fn [k, v, _] -> %{k => Decimal.to_float(v)} end)
            |> Enum.reduce(&Map.merge/2)
        }
      end)

    expenses =
      monthly_expenses
      |> Enum.filter(fn %{name: name} -> name == category_name end)

    last_12_months =
      Timex.Interval.new(
        from:
          Timex.today()
          |> Timex.shift(months: -11),
        until: Timex.today(),
        step: [months: 1],
        right_open: false
      )
      |> Enum.map(&Timex.format!(&1, "%Y-%m", :strftime))

    category_budget = Management.get_category_by_name(category_name).budget

    budget =
      expenses
      |> List.first()
      |> Map.get(:data)
      |> Enum.map(fn {k, i} -> {k, category_budget} end)
      |> Enum.into(%{})

    spending =
      expenses
      |> List.first()
      |> Map.get(:data)
      |> Map.take(last_12_months)
      |> Map.values()
      |> Enum.sum()
      |> Kernel./(12)

    average_monthly_expenses =
      monthly_expenses
      |> Enum.reduce(0, fn %{data: expenses}, acc ->
        acc + Enum.reduce(expenses, 0, fn {_, i}, accum -> i + accum end)
      end)
      |> Kernel./(12)

    render(conn, "index.html",
      average_monthly_expenses: average_monthly_expenses,
      monthly_expenses: Jason.encode!(monthly_expenses),
      expenses: Jason.encode!(expenses ++ [%{name: "Budget", data: budget}]),
      budget: category_budget,
      spending: spending,
      category_name: category_name
    )
  end
end
