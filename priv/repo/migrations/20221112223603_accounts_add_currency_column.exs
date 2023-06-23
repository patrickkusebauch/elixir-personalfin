defmodule Personalfin.Repo.Migrations.AccountsAddCurrencyColumn do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add :currency, :string
    end
  end
end
