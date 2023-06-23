defmodule Personalfin.Repo.Migrations.CreateStocks do
  use Ecto.Migration

  def change do
    create table(:stocks) do
      add :name, :string
      add :amount, :float
      add :broker, :string

      timestamps()
    end
  end
end
