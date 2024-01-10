defmodule Discuss.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :slug, :string
      add :body, :string

      timestamps()
    end

    create unique_index(:posts, [:slug])
  end
end
