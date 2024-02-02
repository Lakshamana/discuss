defmodule Discuss.Repo.Migrations.AlterPostsTable do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      modify :body, :text
      add :deleted_at, :utc_datetime
    end
  end
end
