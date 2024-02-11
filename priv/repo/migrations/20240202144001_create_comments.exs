defmodule Discuss.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :content, :text
      add :parent_id, references(:comments, on_delete: :nothing, type: :binary_id)
      add :deleted_at, :utc_datetime

      timestamps()
    end

    create index(:comments, [:parent_id])
  end
end
