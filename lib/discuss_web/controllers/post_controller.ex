defmodule DiscussWeb.PostController do
  use DiscussWeb, :controller

  alias Discuss.Topics
  alias Discuss.Topics.Post

  def index(conn, _params) do
    posts = Topics.list_posts()
    render(conn, :index, posts: posts)
  end

  def new(conn, _params) do
    changeset = Topics.change_post(%Post{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    case Topics.create_post(Post.create_slug(post_params)) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: ~p"/posts/#{post.slug}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset |> dbg())
    end
  end

  def show(conn, %{ "slug" => slug }) do
    with {:ok, post} <- Topics.get_post_by_slug(slug) do
      render(conn, :show, post: post)
    else
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Post not found.")
        |> redirect(to: ~p"/posts")
    end
  end

  def edit(conn, %{ "slug" => slug }) do
    with {:ok, post} <- Topics.get_post_by_slug(slug) do
      changeset = Topics.change_post(post)
      render(conn, :edit, post: post, changeset: changeset)
    else
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Post not found.")
        |> redirect(to: ~p"/posts")
    end
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Topics.get_post!(id)

    case Topics.update_post(post, Post.create_slug(post_params)) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: ~p"/posts/#{post.slug}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Topics.get_post!(id)
    {:ok, _post} = Topics.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: ~p"/posts")
  end
end
