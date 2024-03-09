defmodule DiscussWeb.PostLive.OptionsMenuComponent do
  use DiscussWeb, :live_component

  slot :items, doc: "The list of items to display in the options menu"

  @impl true
  def render(assigns) do
    ~H"""
    <div class="hover:bg-default rounded-full border-0 flex justify-center items-center py-1 outline-none options-menu">
      <input type="checkbox" id={"options-toggle-#{@post.id}"} />
      <label class="icon-options-menu" for={"options-toggle-#{@post.id}"}>
        <span class="icon-options">&nbsp;</span>
      </label>
      <div class="options-menu__drawer border rounded-md">
        <ul role="list" class="cursor-pointer">
          <li class="flex justify-between items-center pb-1 hover:bg-default">
            <.link patch={~p"/posts/#{@post.slug}"}>
              <div class="flex space-x-1 items-center p-2">
                <span class="icon-post-edit"></span>
                <span class="text-sm">Edit</span>
              </div>
            </.link>
          </li>
          <li
            class="flex justify-between items-center hover:bg-default"
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
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end
end
