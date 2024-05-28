defmodule Discuss.Repo.Migrations.AddUserIdPostsAndVotes do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
    end

    alter table(:post_votes) do
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
    end

    create unique_index(:post_votes, [:user_id, :post_id])
  end
end
