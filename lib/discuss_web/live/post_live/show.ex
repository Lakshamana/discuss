defmodule DiscussWeb.PostLive.Show do
  use DiscussWeb, :live_view

  alias Discuss.Topics

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"slug" => slug}, _, socket) do
    result = Topics.get_post_by_slug(slug)

    case result do
      {:ok, post} ->
        {:noreply,
         socket
         |> assign(:page_title, page_title(socket.assigns.live_action))
         |> assign(:post, post || nil)}

      _ ->
        {:noreply, socket |> put_flash(:error, "Post not found") |> push_navigate(to: ~p"/posts")}
    end
  end

  defp page_title(:show), do: "Show Post"
  defp page_title(:edit), do: "Edit Post"
end
