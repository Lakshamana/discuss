defmodule Discuss.Topics.CommentVote do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "comment_votes" do
    field :mode, Ecto.Enum, values: [:upvote, :downvote]
    field :comment_id, :binary_id
    field :user_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(comment_vote, attrs) do
    comment_vote
    |> cast(attrs, [:mode, :comment_id, :user_id])
    |> validate_required([:mode, :comment_id, :user_id])
  end
end
