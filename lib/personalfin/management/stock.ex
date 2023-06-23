defmodule Personalfin.Management.Stock do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "stocks" do
    field :amount, :float
    field :broker, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(stock, attrs) do
    stock
    |> cast(attrs, [:name, :amount, :broker])
    |> validate_required([:name, :amount, :broker])
  end
end
