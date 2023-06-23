defmodule PersonalfinWeb.Management.TransactionController do
  use PersonalfinWeb, :controller

  alias Personalfin.Management
  alias Personalfin.Management.Transaction
  alias Personalfin.Management.TransactionCategory

  def index(conn, _params) do
    categories = Management.list_categories()
    transactions = Management.list_transaction_without_category()
    render(conn, "index.html", categories: categories, transactions: transactions)
  end

  def update_categories(conn, params) do
    params["category_budget"]
    |> Enum.each(fn {id, budget} ->
      Personalfin.Repo.get!(TransactionCategory, id)
      |> Ecto.Changeset.change(budget: budget |> String.to_integer())
      |> Personalfin.Repo.update()
    end)

    conn
    |> redirect(to: Routes.management_transaction_path(conn, :index))
  end

  def update_transactions(conn, params) do
    params["transaction_category_id"]
    |> Enum.reject(fn {_, i} -> i == "" end)
    |> Enum.each(fn {id, category_id} ->
      Personalfin.Repo.get!(Transaction, id)
      |> Personalfin.Repo.preload(:transaction_category)
      |> Ecto.Changeset.change(
        transaction_category: Personalfin.Repo.get!(TransactionCategory, category_id)
      )
      |> Personalfin.Repo.update()
    end)

    conn
    |> redirect(to: Routes.management_transaction_path(conn, :index))
  end
end
