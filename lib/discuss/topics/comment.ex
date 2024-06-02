defmodule Discuss.Topics.Comment do
  alias Discuss.Topics.CommentVote
  alias Discuss.Topics.Comment
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "comments" do
    field :content, :string
    field :parent_id, :binary_id
    field :post_id, :binary_id
    field :deleted_at, :utc_datetime
    has_many :replies, Comment, foreign_key: :parent_id, references: :id
    has_many :votes, CommentVote, foreign_key: :comment_id, references: :id
    field :reply_count, :integer, virtual: true
    field :score, :integer, virtual: true
    field :user_voted, Ecto.Enum, values: [:upvote, :downvote], virtual: true

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content, :deleted_at, :post_id, :parent_id])
    |> validate_required([:content])
  end
end
