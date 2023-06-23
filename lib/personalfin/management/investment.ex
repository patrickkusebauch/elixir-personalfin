defmodule Personalfin.Management.Investment do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "investments" do
    field :broker, :string
    field :name, :string
    field :value, :float

    timestamps()
  end

  @doc false
  def changeset(investment, attrs) do
    investment
    |> cast(attrs, [:name, :value, :broker])
    |> validate_required([:name, :value, :broker])
  end
end
