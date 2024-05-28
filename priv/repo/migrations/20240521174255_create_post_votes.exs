defmodule Discuss.Repo.Migrations.CreatePostVotes do
  use Ecto.Migration

  def change do
    create table(:post_votes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :mode, :string
      add :post_id, references(:posts, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:post_votes, [:post_id])
  end
end
