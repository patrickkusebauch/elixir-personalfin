defmodule Personalfin.Management.Transaction do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  schema "transaction" do
    field :amount, :decimal
    field :date, :date
    field :notes, :string
    belongs_to :transaction_category, Personalfin.Management.TransactionCategory
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:notes])
  end
end
