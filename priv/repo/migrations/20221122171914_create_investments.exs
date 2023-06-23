defmodule Personalfin.Repo.Migrations.CreateInvestments do
  use Ecto.Migration

  def change do
    create table(:investments) do
      add :name, :string
      add :value, :float
      add :broker, :string

      timestamps()
    end
  end
end
