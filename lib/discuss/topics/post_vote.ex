defmodule Discuss.Topics.PostVote do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "post_votes" do
    field :mode, Ecto.Enum, values: [:upvote, :downvote]
    field :post_id, :binary_id
    field :user_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(post_vote, attrs) do
    post_vote
    |> cast(attrs, [:mode, :post_id, :user_id])
    |> validate_required([:mode, :post_id, :user_id])
  end
end
