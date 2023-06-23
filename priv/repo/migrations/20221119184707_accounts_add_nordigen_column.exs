defmodule Personalfin.Repo.Migrations.AccountsAddNordigenColumn do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add :nordigen, :string, null: true
    end
  end
end
