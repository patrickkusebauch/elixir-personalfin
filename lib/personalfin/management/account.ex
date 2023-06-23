defmodule Personalfin.Management.Account do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field :balance, :decimal
    field :iban, :string
    field :last_access, :utc_datetime
    field :name, :string
    field :currency, :string
    field :nordigen, :string

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:iban, :name, :currency, :balance, :last_access, :nordigen])
    |> validate_required([:iban, :name, :currency, :balance, :last_access])
  end
end
