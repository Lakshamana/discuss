defmodule Discuss.Topics.Post do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "posts" do
    field :title, :string
    field :body, :string
    field :slug, :string

    timestamps()
  end

  defp random_string(n \\ 16) do
    for _ <- 1..n, into: "", do: <<Enum.random('0123456789abcdef')>>
  end

  defp slugify(term) when is_binary(term) do
    base_term = term
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
