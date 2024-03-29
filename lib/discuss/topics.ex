defmodule Discuss.Topics do
  @moduledoc """
  The Topics context.
  """

  import Ecto.Query, warn: false
  alias Discuss.Repo

  alias Discuss.Topics.{Post, Comment}

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    post =
      from p in Post,
        left_join: c in assoc(p, :comments),
        on: c.post_id == p.id,
        group_by: p.id,
        select: %{p | comment_count: count(c.id)}

    Repo.all(post)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id)

  @doc """
  Gets a single post by slug.

  Returns {:error, :not_found} if the Post does not exist.

  ## Examples

    iex> get_post_by_slug("slug")
            {:ok, %Post{}}
    iex> get_post_by_slug("bad_slug")
            {:error, :not_found}
  """
  def get_post_by_slug(slug) do
    post =
      Post
      |> where(slug: ^slug)
      |> Repo.one()

    case post do
      nil ->
        {:error, :not_found}

      post ->
        {:ok, post}
    end
  end

  @doc """
  Gets a single post by slug.

  Returns {:error, :not_found} if the Post does not exist.

  ## Examples

    iex> get_post_by_slug_with_comments("slug")
            {:ok, %Post{..., comments: [%Comments{}, ...]}}
    iex> get_post_by_slug_with_comments("bad_slug")
            {:error, :not_found}
  """
  def get_post_by_slug_with_comments(slug) do
    comments_replies_count =
      from c in Comment,
        left_join: r in assoc(c, :replies),
        on: r.parent_id == c.id,
        where: is_nil(c.parent_id),
        group_by: c.id,
        select: %{c | reply_count: count(r.id)}

    post =
      from p in Post,
        left_join: c in assoc(p, :comments),
        on: c.post_id == p.id,
        preload: [comments: ^comments_replies_count],
        where: p.slug == ^slug,
        group_by: p.id,
        select: %{p | comment_count: count(c.id)}

    case Repo.one(post) do
      nil ->
        {:error, :not_found}

      post ->
        {:ok, post}
    end
  end

  @doc """
  Get all replies for a post comment.

  ## Examples

    iex> get_replies_for_comment(<comment_id>)
            [%Comment{}, ...]
    iex> get_replies_for_comment(<comment_id)
            []
  """
  def get_replies_for_comment(comment_id) do
    query =
      from c in Comment,
        left_join: r in assoc(c, :replies),
        on: r.parent_id == c.id,
        where: c.parent_id == ^comment_id,
        group_by: c.id,
        select: %{c | reply_count: count(r.id)}

    Repo.all(query)
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  @doc """
  Returns the list of comments for a given post.

  ## Examples

      iex> list_comments_for_post()
      [%Comment{}, ...]

  """
  def list_comments_for_post(post_id) do
    query = from(comment in Comment, where: comment.post_id == ^post_id)
    Repo.all(query)
  end

  @doc """
  Returns the list of comments for post

  ## Examples

      iex> list_comments()
      [%Comment{}, ...]

  """
  def list_comments do
    Repo.all(Comment)
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment!(id), do: Repo.get!(Comment, id)

  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment(attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a comment.

  ## Examples

      iex> update_comment(comment, %{field: new_value})
      {:ok, %Comment{}}

      iex> update_comment(comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a comment.

  ## Examples

      iex> delete_comment(comment)
      {:ok, %Comment{}}

      iex> delete_comment(comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment(%Comment{} = comment) do
    comment
    |> Comment.changeset(%{deleted_at: DateTime.utc_now()})
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{data: %Comment{}}

  """
  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end
end
