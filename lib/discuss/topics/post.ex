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

  defp slugify(term) when is_binary(term) do
    term
    |> String.downcase()
    |> String.trim()
    |> String.normalize(:nfd)
    |> String.replace(~r/[^a-z0-9\s-]/u, "-")
    |> String.replace(~r/[\s-]+/, "-", global: true)
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
