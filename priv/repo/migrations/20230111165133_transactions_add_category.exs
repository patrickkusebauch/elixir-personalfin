defmodule Personalfin.Repo.Migrations.TransactionsAddCategory do
  use Ecto.Migration

  def change do
    create table(:transaction_category) do
      add :name, :string
      add :budget, :integer
    end

    alter table(:transaction) do
      add(:transaction_category_id, references(:transaction_category, on_delete: :nilify_all),
        primary_key: false,
        null: true
      )
    end
  end
end
