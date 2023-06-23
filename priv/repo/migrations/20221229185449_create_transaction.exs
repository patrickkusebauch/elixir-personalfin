defmodule Personalfin.Repo.Migrations.CreateTransaction do
  use Ecto.Migration

  def change do
    create table(:transaction) do
      add :amount, :decimal
      add :date, :date
    end
  end
end
