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
        post_score: 0,
        is_commenting: false,
        post_comment_number: 0
      })
    }
  end

  @impl true
  def handle_params(%{"slug" => slug}, _, socket) do
    %{current_user: current_user} = socket.assigns

    case Topics.get_post_by_slug_with_comments(slug, current_user && current_user.id) do
      {:ok, post} ->
        {:noreply,
         socket
         |> assign(:page_title, page_title(socket.assigns.live_action))
         |> stream(:comments, post.comments)
         |> assign(
           post: post || nil,
           post_score: post.score,
           voted_up: post && post.user_voted == :upvote,
           voted_down: post && post.user_voted == :downvote
         )}

      _ ->
        {:noreply, socket |> put_flash(:error, "Post not found") |> push_navigate(to: ~p"/posts")}
    end
  end

  defp page_title(:show), do: "Show Post"
  defp page_title(:edit), do: "Edit Post"

  @impl true
  def handle_event(_event_name, _value, %{assigns: %{current_user: nil}} = socket) do
    {:noreply, redirect(socket, to: ~p"/users/log_in")}
  end

  @impl true
  def handle_event("upvote", _value, socket) do
    %{current_user: current_user} = socket.assigns

    mode = if socket.assigns.voted_up, do: :neutral, else: :upvote

    case Topics.add_vote_post(%{
           mode: mode,
           post_id: socket.assigns.post.id,
           user_id: current_user.id
         }) do
      {:ok, _} ->
        %{score: score} = Topics.get_post_score(socket.assigns.post.id)

        {:noreply,
         assign(socket, %{
           voted_up: !socket.assigns.voted_up,
           voted_down: false,
           post_score: score
         })}

      _ ->
        {:noreply, socket |> put_flash(:error, "Error upvoting")}
    end
  end

  @impl true
  def handle_event("downvote", _value, socket) do
    %{current_user: current_user} = socket.assigns

    mode = if socket.assigns.voted_down, do: :neutral, else: :downvote

    case Topics.add_vote_post(%{
           mode: mode,
           post_id: socket.assigns.post.id,
           user_id: current_user.id
         }) do
      {:ok, _} ->
        %{score: score} = Topics.get_post_score(socket.assigns.post.id)

        {:noreply,
         assign(socket, %{
           voted_down: !socket.assigns.voted_down,
           voted_up: false,
           post_score: score
         })}

      _ ->
        {:noreply, socket |> put_flash(:error, "Error downvoting")}
    end
  end

  @impl true
  def handle_event("show_comment_textarea", _value, socket) do
    {:noreply, assign(socket, is_commenting: !socket.assigns.is_commenting)}
  end

  def handle_info(_event, %{assigns: %{current_user: nil}} = socket) do
    {:noreply, redirect(socket, to: ~p"/users/log_in")}
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
  def handle_info(%{event: "delete_comment", post_id: _}, socket) do
    %{post: post, current_user: current_user} = socket.assigns

    {:ok, result} =
      Topics.get_post_by_slug_with_comments(post.slug, current_user && current_user.id)

    {:noreply, socket |> stream(:comments, result.comments)}
  end

  @impl true
  def handle_info({CommentComponent, "cancel_comment"}, socket) do
    {:noreply, assign(socket, is_commenting: false)}
  end
end
