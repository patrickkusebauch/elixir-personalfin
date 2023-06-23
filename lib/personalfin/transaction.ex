defmodule Personalfin.Transaction do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, []}
  schema "transaction" do
    field :amount, :decimal
    field :date, :date
    field :notes, :string
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:id, :amount, :date, :notes])
    |> validate_required([:id, :amount, :date])
  end
end
