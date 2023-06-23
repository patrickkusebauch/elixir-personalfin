defmodule Personalfin.Repo.Migrations.TransactionsAddNotes do
  use Ecto.Migration

  def change do
    alter table(:transaction) do
      add :notes, :text
    end
  end
end
