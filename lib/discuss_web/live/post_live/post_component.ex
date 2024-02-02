defmodule DiscussWeb.PostLive.PostComponent do
  use DiscussWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
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
          <button phx-click="voted_up" phx-target={@myself}>
            <span class={["icon-arrow-up", (@voted_up || false) && "arrow-selected"]}></span>
          </button>
          <span class="post-vote-number">5</span>
          <button phx-click="voted_down" phx-target={@myself}>
            <span class={["icon-arrow-down", (@voted_down || false) && "arrow-selected"]}></span>
          </button>
        </div>
        <div class="bg-gray-100 rounded-full border-0 px-3 space-x-1 flex items-center relative py-1 outline-none">
          <span class="icon-comment"></span>
          <span class="post-comment-number">10</span>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, assign(socket, %{ voted_up: false, voted_down: false })}
  end

  @impl true
  def handle_event("voted_up", _value, socket) do
    {:noreply, assign(socket, %{ voted_up: !socket.assigns.voted_up, voted_down: false })}
  end

  @impl true
  def handle_event("voted_down", _value, socket) do
    {:noreply, assign(socket, %{ voted_up: false, voted_down: !socket.assigns.voted_down })}
  end
end
