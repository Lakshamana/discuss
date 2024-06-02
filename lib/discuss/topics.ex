defmodule Discuss.Topics do
  @moduledoc """
  The Topics context.
  """

  import Ecto.Query, warn: false
  alias Discuss.Topics.{PostVote, CommentVote}
  alias Discuss.Repo

  alias Discuss.Topics.{Post, Comment}

  defp maybe_auth_query?(query, user_id, callback) do
    if user_id do
      callback.(query)
    else
      query
    end
  end

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts(user_id \\ nil) do
    query =
      from p in Post,
        left_join: c in assoc(p, :comments), on: c.post_id == p.id,
        left_join: pv in assoc(p, :votes), on: pv.post_id == p.id,
        group_by: p.id,
        select_merge: %{
          p
          | comment_count: count(c.id) |> filter(is_nil(c.deleted_at)),
            score:
              fragment(
                "coalesce(sum(distinct case ?.mode when 'upvote' then 1 when 'downvote' then -1 end), 0)",
                pv
              )
        }

    query =
      maybe_auth_query?(
        query,
        user_id,
        &(&1
          |> join(:left, [p], pv2 in PostVote,
            on: pv2.post_id == p.id and pv2.user_id == ^user_id
          )
          |> select_merge([p, ..., pv2], %{user_voted: max(pv2.mode)}))
      )

    Repo.all(query)
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
  def get_post_by_slug_with_comments(slug, user_id \\ nil) do
    comments_replies_count =
      from c in Comment,
        left_join: r in assoc(c, :replies), on: r.parent_id == c.id,
        left_join: cv in assoc(c, :votes), on: cv.comment_id == c.id,
        where: is_nil(c.parent_id),
        group_by: c.id,
        select: %{
          c
          | reply_count: count(r.id) |> filter(is_nil(r.deleted_at)),
            score:
              fragment(
                "coalesce(sum(distinct case ?.mode when 'upvote' then 1 when 'downvote' then -1 end), 0)",
                cv
              )
        }

    comments_replies_count =
      maybe_auth_query?(
        comments_replies_count,
        user_id,
        &(&1
          |> join(:left, [c], cv2 in CommentVote,
            on: cv2.comment_id == c.id and cv2.user_id == ^user_id
          )
          |> select_merge([c, ..., cv2], %{user_voted: max(cv2.mode)}))
      )

    query =
      from p in Post,
        left_join: c in assoc(p, :comments), on: c.post_id == p.id,
        left_join: pv in assoc(p, :votes), on: pv.post_id == p.id,
        preload: [comments: ^comments_replies_count],
        where: p.slug == ^slug,
        group_by: p.id,
        select: %{
          p
          | comment_count: count(c.id) |> filter(is_nil(c.deleted_at)),
            score:
              fragment(
                "coalesce(sum(distinct case ?.mode when 'upvote' then 1 when 'downvote' then -1 end), 0)",
                pv
              )
        }

    query =
      maybe_auth_query?(
        query,
        user_id,
        &(&1
          |> join(:left, [p], pv2 in PostVote,
            on: pv2.post_id == p.id and pv2.user_id == ^user_id
          )
          |> select_merge([p, ..., pv2], %{user_voted: max(pv2.mode)}))
      )

    case Repo.one(query) do
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
  def get_replies_for_comment(comment_id, user_id \\ nil) do
    query =
      from c in Comment,
        left_join: r in assoc(c, :replies), on: r.parent_id == c.id,
        left_join: cv in assoc(c, :votes), on: cv.comment_id == c.id,
        where: c.parent_id == ^comment_id,
        group_by: c.id,
        select: %{
          c
          | reply_count: count(r.id) |> filter(not is_nil(r.id)),
            score:
              fragment(
                "coalesce(sum(distinct case ?.mode when 'upvote' then 1 when 'downvote' then -1 end), 0)",
                cv
              )
        }

    query =
      maybe_auth_query?(
        query,
        user_id,
        &(&1
          |> join(:left, [c], cv2 in CommentVote,
            on: cv2.comment_id == c.id and cv2.user_id == ^user_id
          )
          |> select_merge([c, ..., cv2], %{user_voted: max(cv2.mode)}))
      )

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
      {:error, %Ecto

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
  Adds a vote to a comment.
  """
  def add_vote_comment(attrs)

  def add_vote_comment(%{mode: :neutral, comment_id: comment_id, user_id: user_id}) do
    Repo.get_by(CommentVote, comment_id: comment_id, user_id: user_id)
    |> case do
      nil ->
        {:ok, nil}

      vote ->
        Repo.delete(vote)
    end
  end

  def add_vote_comment(%{mode: _, comment_id: comment_id, user_id: user_id} = attrs) do
    result =
      from(cv in CommentVote, where: cv.comment_id == ^comment_id and cv.user_id == ^user_id)
      |> Repo.one()
      |> case do
        nil ->
          %CommentVote{}

        vote ->
          vote
      end
      |> CommentVote.changeset(attrs)
      |> Repo.insert_or_update()

    case result do
      {:error, _} -> {:ok, nil}
      vote -> {:ok, vote}
    end
  end

  @doc """
  Adds a vote to a post.
  """
  def add_vote_post(attrs)

  def add_vote_post(%{mode: :neutral, post_id: post_id, user_id: user_id}) do
    Repo.get_by(PostVote, post_id: post_id, user_id: user_id)
    |> case do
      nil ->
        {:ok, nil}

      vote ->
        Repo.delete(vote)
    end
  end

  def add_vote_post(%{mode: _, post_id: post_id, user_id: user_id} = attrs) do
    result =
      from(pv in PostVote, where: pv.post_id == ^post_id and pv.user_id == ^user_id)
      |> Repo.one()
      |> case do
        nil ->
          %PostVote{}

        vote ->
          vote
      end
      |> PostVote.changeset(attrs)
      |> Repo.insert_or_update()

    case result do
      {:error, _} -> {:ok, nil}
      vote -> vote
    end
  end

  @doc """
  Get post score
  """
  def get_post_score(post_id) do
    query =
      from p in PostVote,
        where: p.post_id == ^post_id,
        select: %{
          score:
            fragment(
              "coalesce(sum(distinct case ?.mode when 'upvote' then 1 when 'downvote' then -1 end), 0)",
              p
            )
        }

    Repo.one(query)
  end

  @doc """
  Get comment score
  """
  def get_comment_score(comment_id) do
    query =
      from cv in CommentVote,
        where: cv.comment_id == ^comment_id,
        select: %{
          score:
            fragment(
              "coalesce(sum(distinct case ?.mode when 'upvote' then 1 when 'downvote' then -1 end), 0)",
              cv
            )
        }

    Repo.one(query)
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
