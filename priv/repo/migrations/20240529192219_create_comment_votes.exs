defmodule Discuss.Repo.Migrations.CreateCommentVotes do
  use Ecto.Migration

  def change do
    create table(:comment_votes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :mode, :string
      add :comment_id, references(:comments, on_delete: :nothing, type: :binary_id)
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:comment_votes, [:comment_id])
    create index(:comment_votes, [:user_id])
  end
end
