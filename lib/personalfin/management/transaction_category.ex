defmodule Personalfin.Management.TransactionCategory do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "transaction_category" do
    field :name, :string
    field :budget, :integer

    has_many :transactions, Personalfin.Management.Transactions,
      foreign_key: :transaction_category_id
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:name, :budget])
    |> validate_required([:name, :budget])
  end
end
