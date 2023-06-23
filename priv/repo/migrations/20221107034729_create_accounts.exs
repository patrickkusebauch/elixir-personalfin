defmodule Personalfin.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :iban, :string
      add :name, :string
      add :balance, :decimal
      add :last_access, :utc_datetime

      timestamps()
    end
  end
end
