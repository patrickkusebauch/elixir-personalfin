defmodule Personalfin.Repo.Migrations.CreateCrypto do
  use Ecto.Migration

  def change do
    create table(:crypto) do
      add :name, :string
      add :amount, :float
      add :broker, :string

      timestamps()
    end
  end
end
