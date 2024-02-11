defmodule Discuss.Repo.Migrations.AlterPostsCommentAddPostId do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      add :post_id, references(:posts, on_delete: :nothing, type: :binary_id)
    end
  end
end
