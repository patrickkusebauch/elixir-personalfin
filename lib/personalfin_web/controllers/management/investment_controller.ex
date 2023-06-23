defmodule PersonalfinWeb.Management.InvestmentController do
  use PersonalfinWeb, :controller

  alias Personalfin.Management
  alias Personalfin.Management.Investment

  def index(conn, _params) do
    investments = Management.list_investments()
    total = investments |> Enum.reduce(0.0, fn investment, acc -> investment.value + acc end)
    render(conn, "index.html", investments: investments, total: total)
  end

  def new(conn, _params) do
    changeset = Management.change_investment(%Investment{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"investment" => investment_params}) do
    case Management.create_investment(investment_params) do
      {:ok, investment} ->
        conn
        |> put_flash(:info, "Investment created successfully.")
        |> redirect(to: Routes.management_investment_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    investment = Management.get_investment!(id)
    changeset = Management.change_investment(investment)
    render(conn, "edit.html", investment: investment, changeset: changeset)
  end

  def update(conn, %{"id" => id, "investment" => investment_params}) do
    investment = Management.get_investment!(id)

    case Management.update_investment(investment, investment_params) do
      {:ok, investment} ->
        conn
        |> put_flash(:info, "Investment updated successfully.")
        |> redirect(to: Routes.management_investment_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", investment: investment, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    investment = Management.get_investment!(id)
    {:ok, _investment} = Management.delete_investment(investment)

    conn
    |> put_flash(:info, "Investment deleted successfully.")
    |> redirect(to: Routes.management_investment_path(conn, :index))
  end
end
