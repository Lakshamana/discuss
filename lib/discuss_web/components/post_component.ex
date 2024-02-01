defmodule DiscussWeb.PostComponent do
  use Phoenix.Component

  @doc """
  Renders a single post view.
  """
  attr :post, Discuss.Topics.Post, required: true
  attr :voted_up, :boolean, default: false
  attr :voted_down, :boolean, default: false

  def post_view(assigns) do
    ~H"""
    <hr class="my-4" />
    <.link href={~p"/posts/#{@post.slug}"}>
      <div class="block relative cursor-pointer">
        <div>
          <dl class="flex flex-column">
            <dt class="sr-only">Title</dt>
            <dd class="font-semibold text-base"><%= @post.title %></dd>
          </dl>
        </div>
        <div>
          <dl class="flex flex-column">
            <dt class="sr-only">Body</dt>
            <dd class="text-wrap text-sm"><%= @post.body %></dd>
          </dl>
        </div>
      </div>
    </.link>

    <div class="flex flex-row justify-start my-3 space-x-3 text-sm items-center">
      <div class="bg-gray-100 rounded-full group justify-center border-0 inline-flex px-3 space-x-2 items-center relative py-1 outline-none">
        <button phx-click="vote" phx-click-source="voted_up">
          <span class={["icon-arrow-up", @voted_up && "arrow-selected"]}></span>
        </button>
        <span class="post-vote-number">5</span>
        <button phx-click="vote" phx-click-source="voted_down">
          <span class={["icon-arrow-down", @voted_down && "arrow-selected"]}></span>
        </button>
      </div>
      <div class="bg-gray-100 rounded-full border-0 px-3 space-x-1 flex items-center relative py-1 outline-none">
        <span class="icon-comment"></span>
        <span class="post-comment-number">10</span>
      </div>
    </div>
    """
  end
end
