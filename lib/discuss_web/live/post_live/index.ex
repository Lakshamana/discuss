defmodule DiscussWeb.PostLive.Index do
  use DiscussWeb, :live_view

  alias Discuss.Topics
  alias Discuss.Topics.Post

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :posts, Topics.list_posts())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"slug" => slug}) do
    {:ok, post} = Topics.get_post_by_slug(slug)
    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, post)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:post, nil)
  end

  @impl true
  def handle_info({DiscussWeb.PostLive.FormComponent, {:saved, _}}, socket) do
    {:noreply, stream(socket, :posts, Topics.list_posts())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Topics.get_post!(id)
    {:ok, _} = Topics.delete_post(post)

    {:noreply, stream(socket, :posts, Topics.list_posts())}
  end
end
