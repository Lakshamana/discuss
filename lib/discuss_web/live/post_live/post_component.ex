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
            <dl class="flex flex-row justify-between">
              <dt class="sr-only xs:text-sm sm: sm:text-sm">Title</dt>
              <dd class="font-semibold sm:text-sm"><%= @post.title %></dd>
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
      <div class="flex flex-row justify-start mt-3 text-sm items-center">
        <div class="bg-gray-100 rounded-full border-0 px-3 space-x-1 flex items-center relative py-1 outline-none mr-2">
          <button phx-click="voted_up" phx-target={@myself}>
            <span class={["icon-arrow-up", (@voted_up || false) && "arrow-selected"]}></span>
          </button>
          <span class="post-vote-number">5</span>
          <button phx-click="voted_down" phx-target={@myself}>
            <span class={["icon-arrow-down", (@voted_down || false) && "arrow-selected"]}></span>
          </button>
        </div>
        <div class="bg-gray-100 rounded-full border-0 px-3 space-x-1 flex items-center relative py-1 outline-none mr-auto">
          <span class="icon-comment"></span>
          <span class="post-comment-number">10</span>
        </div>
        <div class="hover:bg-gray-100 rounded-full border-0 flex justify-center items-center py-1 outline-none options-menu">
          <input type="checkbox" id={"options-toggle-#{@post.id}"} />
          <label class="icon-options-menu" for={"options-toggle-#{@post.id}"}>
            <span class="icon-options">&nbsp;</span>
          </label>
          <div class="options-menu__drawer border rounded-md">
            <ul role="list" class="cursor-pointer">
              <li class="flex justify-between items-center pb-1 hover:bg-gray-100">
                <.link patch={~p"/posts/#{@post.slug}/edit"}>
                  <div class="flex space-x-1 items-center p-2">
                    <span class="icon-post-edit"></span>
                    <span class="text-sm">Edit</span>
                  </div>
                </.link>
              </li>
              <li
                class="flex justify-between items-center hover:bg-gray-100"
                phx-click={JS.push("delete", value: %{id: @post.id}) |> hide("##{@id}")}
                data-confirm="Are you sure?"
              >
                <div class="flex space-x-1 items-center p-2">
                  <span class="icon-post-delete"></span>
                  <span class="text-sm">Delete</span>
                </div>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, assign(socket, %{voted_up: false, voted_down: false})}
  end

  @impl true
  def handle_event("voted_up", _value, socket) do
    {:noreply, assign(socket, %{voted_up: !socket.assigns.voted_up, voted_down: false})}
  end

  @impl true
  def handle_event("voted_down", _value, socket) do
    {:noreply, assign(socket, %{voted_up: false, voted_down: !socket.assigns.voted_down})}
  end
end
