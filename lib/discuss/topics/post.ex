defmodule Discuss.Topics.Post do
  alias Discuss.Topics.PostVote
  alias Discuss.Topics.Comment
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "posts" do
    field :title, :string
    field :body, :string
    field :slug, :string
    has_many :comments, Comment, foreign_key: :post_id, references: :id
    has_many :votes, PostVote, foreign_key: :post_id, references: :id
    field :comment_count, :integer, virtual: true
    field :score, :integer, virtual: true
    field :user_voted, Ecto.Enum, values: [:upvote, :downvote], virtual: true

    timestamps()
  end

  defp random_string(n \\ 16) do
    for _ <- 1..n, into: "", do: <<Enum.random(~c"0123456789abcdef")>>
  end

  defp slugify(term) when is_binary(term) do
    base_term =
      term
      |> String.downcase()
      |> String.normalize(:nfd)
      |> String.replace(~r/[^a-z0-9\s-]/u, " ")
      |> String.replace(~r/[\s-]+/, "-", global: true)
      |> String.replace(~r/-$/, "")
      |> String.trim()
      |> String.slice(0, 39)

    "#{base_term}-#{random_string()}"
  end

  defp slugify(_), do: ""

  @doc """
  Create a slug from the title and assign it to the `slug` field.

  Returns a map with the `slug` field set.

    ## Examples
        iex> Post.create_slug(%{"title" => "My First Post"})
        %{"title" => "My First Post", "slug" => "wawa-cat-64469dad10ee882a"}
  """
  def create_slug(%{"title" => title} = params) do
    Map.put(params, "slug", slugify(title))
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :slug, :body])
    |> validate_required([:title, :slug, :body])
    |> unique_constraint(:slug)
  end
end
