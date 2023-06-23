defmodule PersonalfinWeb.Management.StockController do
  use PersonalfinWeb, :controller

  alias Personalfin.Management
  alias Personalfin.Management.Stock
  alias Personalfin.Rates

  def index(conn, _params) do
    stocks = Management.list_stocks()
    total = Rates.stock_total(stocks)
    render(conn, "index.html", stocks: stocks, total: total)
  end

  def new(conn, _params) do
    changeset = Management.change_stock(%Stock{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"stock" => stock_params}) do
    case Management.create_stock(stock_params) do
      {:ok, stock} ->
        conn
        |> put_flash(:info, "Stock created successfully.")
        |> redirect(to: Routes.management_stock_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    stock = Management.get_stock!(id)
    changeset = Management.change_stock(stock)
    render(conn, "edit.html", stock: stock, changeset: changeset)
  end

  def update(conn, %{"id" => id, "stock" => stock_params}) do
    stock = Management.get_stock!(id)

    case Management.update_stock(stock, stock_params) do
      {:ok, stock} ->
        conn
        |> put_flash(:info, "Stock updated successfully.")
        |> redirect(to: Routes.management_stock_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", stock: stock, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    stock = Management.get_stock!(id)
    {:ok, _stock} = Management.delete_stock(stock)

    conn
    |> put_flash(:info, "Stock deleted successfully.")
    |> redirect(to: Routes.management_stock_path(conn, :index))
  end
end
