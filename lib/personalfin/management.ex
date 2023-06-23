defmodule Personalfin.Management do
  @moduledoc false

  import Ecto.Query, warn: false
  alias Personalfin.Management.Account
  alias Personalfin.Repo

  def list_accounts do
    Account |> order_by(:iban) |> Repo.all()
  end

  def list_categories do
    Personalfin.Management.TransactionCategory |> order_by(:id) |> Repo.all()
  end

  def get_category_by_name(name),
    do: Repo.get_by(Personalfin.Management.TransactionCategory, name: name)

  def list_transaction_without_category do
    Repo.all(
      from t in Personalfin.Management.Transaction,
        where: is_nil(t.transaction_category_id),
        where: t.amount < 0,
        order_by: [desc: :date]
    )
  end

  def list_accounts_from_bank(name) do
    like = "#{name}%"
    query = from a in Account, where: ilike(a.name, ^like)
    Repo.all(query)
  end

  def get_account!(id), do: Repo.get!(Account, id)

  def get_account_by_iban_and_currency(iban, currency),
    do: Repo.get_by(Account, iban: iban, currency: currency)

  def get_account_by_name(name), do: Repo.get_by(Account, name: name)

  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  def change_account(%Account{} = account, attrs \\ %{}) do
    Account.changeset(account, attrs)
  end

  alias Personalfin.Management.Investment

  @doc """
  Returns the list of investments.

  ## Examples

      iex> list_investments()
      [%Investment{}, ...]

  """
  def list_investments do
    Repo.all(Investment)
  end

  @doc """
  Gets a single investment.

  Raises `Ecto.NoResultsError` if the Investment does not exist.

  ## Examples

      iex> get_investment!(123)
      %Investment{}

      iex> get_investment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_investment!(id), do: Repo.get!(Investment, id)

  def get_investment_by_name!(name), do: Repo.get_by!(Investment, name: name)

  @doc """
  Creates a investment.

  ## Examples

      iex> create_investment(%{field: value})
      {:ok, %Investment{}}

      iex> create_investment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_investment(attrs \\ %{}) do
    %Investment{}
    |> Investment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a investment.

  ## Examples

      iex> update_investment(investment, %{field: new_value})
      {:ok, %Investment{}}

      iex> update_investment(investment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_investment(%Investment{} = investment, attrs) do
    investment
    |> Investment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a investment.

  ## Examples

      iex> delete_investment(investment)
      {:ok, %Investment{}}

      iex> delete_investment(investment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_investment(%Investment{} = investment) do
    Repo.delete(investment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking investment changes.

  ## Examples

      iex> change_investment(investment)
      %Ecto.Changeset{data: %Investment{}}

  """
  def change_investment(%Investment{} = investment, attrs \\ %{}) do
    Investment.changeset(investment, attrs)
  end

  alias Personalfin.Management.Stock

  @doc """
  Returns the list of stocks.

  ## Examples

      iex> list_stocks()
      [%Stock{}, ...]

  """
  def list_stocks do
    Repo.all(Stock)
  end

  def get_stocks_by_name(name) do
    query = from s in Stock, where: s.name == ^name
    Repo.all(query)
  end

  @doc """
  Gets a single stock.

  Raises `Ecto.NoResultsError` if the Stock does not exist.

  ## Examples

      iex> get_stock!(123)
      %Stock{}

      iex> get_stock!(456)
      ** (Ecto.NoResultsError)

  """
  def get_stock!(id), do: Repo.get!(Stock, id)

  @doc """
  Creates a stock.

  ## Examples

      iex> create_stock(%{field: value})
      {:ok, %Stock{}}

      iex> create_stock(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_stock(attrs \\ %{}) do
    %Stock{}
    |> Stock.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a stock.

  ## Examples

      iex> update_stock(stock, %{field: new_value})
      {:ok, %Stock{}}

      iex> update_stock(stock, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_stock(%Stock{} = stock, attrs) do
    stock
    |> Stock.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a stock.

  ## Examples

      iex> delete_stock(stock)
      {:ok, %Stock{}}

      iex> delete_stock(stock)
      {:error, %Ecto.Changeset{}}

  """
  def delete_stock(%Stock{} = stock) do
    Repo.delete(stock)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking stock changes.

  ## Examples

      iex> change_stock(stock)
      %Ecto.Changeset{data: %Stock{}}

  """
  def change_stock(%Stock{} = stock, attrs \\ %{}) do
    Stock.changeset(stock, attrs)
  end
end
