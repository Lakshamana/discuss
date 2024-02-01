defmodule DiscussWeb.PostHTML do
  use DiscussWeb, :html
  alias DiscussWeb.PostView

  embed_templates "post_html/*"

  @doc """
  Renders a post form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def post_form(assigns)

  @doc """
  Renders a single post view.
  """
  attr :post, Discuss.Topics.Post, required: true
  attr :voted_up, :boolean, default: false
  attr :voted_down, :boolean, default: false

  def post_view(assigns)

  def handle_event("vote", %{"source" => source} = event, socket) do
    IO.inspect(event)

    case source do
      "voted_up" ->
        {:noreply, assign(socket, voted_up: true, voted_down: false)}

      "voted_down" ->
        {:noreply, assign(socket, voted_up: false, voted_down: true)}
    end
  end
end
