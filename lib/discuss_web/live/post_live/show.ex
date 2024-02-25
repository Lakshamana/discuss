defmodule DiscussWeb.PostLive.Show do
  alias DiscussWeb.PostLive.CommentComponent
  use DiscussWeb, :live_view

  alias Discuss.Topics

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      assign(socket, %{
        voted_up: false,
        voted_down: false,
        post_vote_count: 0,
        is_commenting: false,
        post_comment_number: 0
      })
    }
  end

  @impl true
  def handle_params(%{"slug" => slug}, _, socket) do
    result = Topics.get_post_by_slug_with_comments(slug)

    case result do
      {:ok, post} ->
        {:noreply,
         socket
         |> assign(:page_title, page_title(socket.assigns.live_action))
         |> stream(:comments, post.comments)
         |> assign(:post, post || nil)}

      _ ->
        {:noreply, socket |> put_flash(:error, "Post not found") |> push_navigate(to: ~p"/posts")}
    end
  end

  defp page_title(:show), do: "Show Post"
  defp page_title(:edit), do: "Edit Post"

  @impl true
  def handle_event("upvote", _value, socket) do
    %{post_vote_count: post_vote_count, voted_up: voted_up, voted_down: voted_down} =
      socket.assigns

    {
      :noreply,
      assign(socket, %{
        voted_up: !socket.assigns.voted_up,
        voted_down: false,
        post_vote_count:
          cond do
            !voted_up && !voted_down -> post_vote_count + 1
            voted_up && !voted_down -> post_vote_count - 1
            true -> post_vote_count + 2
          end
      })
    }
  end

  @impl true
  def handle_event("downvote", _value, socket) do
    %{post_vote_count: post_vote_count, voted_up: voted_up, voted_down: voted_down} =
      socket.assigns

    {
      :noreply,
      assign(socket, %{
        voted_up: false,
        voted_down: !socket.assigns.voted_down,
        post_vote_count:
          cond do
            !voted_up && !voted_down -> post_vote_count - 1
            !voted_up && voted_down -> post_vote_count + 1
            true -> post_vote_count - 2
          end
      })
    }
  end

  @impl true
  def handle_event("show_comment_textarea", _value, socket) do
    {:noreply, assign(socket, is_commenting: !socket.assigns.is_commenting)}
  end

  @impl true
  def handle_info({CommentComponent, %{id: nil} = comment_params}, socket) do
    save_comment_params = Map.put(comment_params, :post_id, socket.assigns.post.id)

    case Topics.create_comment(save_comment_params) do
      {:ok, _comment} ->
        {
          :noreply,
          socket
          |> push_navigate(to: ~p"/posts/#{socket.assigns.post.slug}")
        }
    end
  end

  @impl true
  def handle_info({CommentComponent, %{id: id} = comment_params}, socket) do
    comment = Topics.get_comment!(id)

    case Topics.update_comment(comment, comment_params) do
      {:ok, _comment} ->
        {
          :noreply,
          socket
          |> push_navigate(to: ~p"/posts/#{socket.assigns.post.slug}")
        }
    end
  end

  @impl true
  def handle_info(%{deleted_comment: deleted_comment}, socket) do
    {:noreply, socket |> stream_delete(:comments, deleted_comment)}
  end

  @impl true
  def handle_info({CommentComponent, "cancel_comment"}, socket) do
    {:noreply, assign(socket, is_commenting: false)}
  end
end
