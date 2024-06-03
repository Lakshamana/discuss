defmodule DiscussWeb.PostLive.CommentComponent do
  alias Discuss.Topics.Comment
  alias Discuss.Topics

  use DiscussWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div
      id={(@comment && "comment-#{@comment.id}") || "new-comment"}
      class={[
        @comment && "pl-2 border-l border-color--#{resolve_color(@level)} hover:border-l-2",
        "flex flex-col w-full"
      ]}
    >
      <div :if={@is_editing} class="flex flex-column flex-wrap w-full">
        <div class="block resize-y rounded-lg border-grey-100 w-full">
          <.simple_form
            for={@form}
            as="comment"
            id="comment-form"
            phx-change="validate"
            phx-target={@myself}
          >
            <.input
              class="max-h-2"
              field={@form[:content]}
              type="textarea"
              placeholder="Write a comment..."
            />
          </.simple_form>
        </div>
        <div class="mr-auto">&nbsp;</div>
        <div class="flex space-x-1 px-md py-1">
          <button
            type="button"
            class="rounded-lg border border-zinc-400 px-3 text-zinc-900 space-x-1 flex items-center relative py-1"
            phx-click="cancel_comment"
            phx-target={@myself}
          >
            Cancel
          </button>
          <button
            type="button"
            class="rounded-lg font-bold border px-3 bg-zinc-900 text-white space-x-1 flex items-center relative py-1"
            phx-click="save_comment"
            phx-target={@myself}
          >
            Save
          </button>
        </div>
      </div>
      <div :if={@comment && !@is_editing}>
        <div>
          <p class="mt-3 py-2 pl-2 text-zinc-700">
            <span :if={@comment.deleted_at}><b>[deleted]</b></span>
            <span :if={!@comment.deleted_at}>
              <%= @comment.content %>
            </span>
          </p>
        </div>
        <div class="flex flex-row justify-start text-xs items-center">
          <div class={[
            "bg-default rounded-full border-0 px-3 space-x-1 flex items-center relative py-1 outline-none mr-2",
            @comment.deleted_at && "btn-disabled"
          ]}>
            <button phx-click={!@comment.deleted_at && JS.push("upvote")} phx-target={@myself}>
              <span class={["icon-arrow-up", (@voted_up || false) && "arrow-selected"]}></span>
            </button>
            <span class="post-vote-number"><%= @score || @comment.score %></span>
            <button phx-click={!@comment.deleted_at && JS.push("downvote")} phx-target={@myself}>
              <span class={["icon-arrow-down", (@voted_down || false) && "arrow-selected"]}></span>
            </button>
          </div>
          <button
            class={[
              "bg-default rounded-full border-0 px-3 space-x-1 flex items-center relative py-1 outline-none mr-2 cursor-pointer",
              @comment.deleted_at && "btn-disabled"
            ]}
            type="button"
            phx-click="reply_comment"
            phx-target={@myself}
            disabled={@comment.deleted_at}
          >
            <span class="post-comment-number">Reply</span>
            <span class="icon-comment"></span>
          </button>
          <div :if={@comment.reply_count == 0} class="mr-auto"></div>
          <button
            :if={!@show_replies && @comment.reply_count > 0}
            class="px-3 space-x-1 flex items-center relative py-1 outline-none mr-auto cursor-pointer hover:underline"
            type="button"
            phx-click="show_replies"
            phx-target={@myself}
          >
            <span class="icon-reply"></span>
            <span class="reply-btn">Show <%= @comment.reply_count %> replie(s)</span>
          </button>
          <button
            :if={@show_replies && @comment.reply_count > 0}
            class="px-3 space-x-1 flex items-center relative py-1 outline-none mr-auto cursor-pointer hover:underline"
            type="button"
            phx-click="show_replies"
            phx-target={@myself}
          >
            <span class="icon-reply icon-reply__collapse"></span>
            <span class="reply-btn">Collapse <%= @comment.reply_count %> replie(s)</span>
          </button>
          <div class="hover:bg-default rounded-full flex justify-center items-center py-1 outline-none options-menu">
            <input type="checkbox" id={"options-toggle-#{@comment.id}"} />
            <label class="icon-options-menu" for={"options-toggle-#{@comment.id}"}>
              <span class="icon-options">&nbsp;</span>
            </label>
            <div class="options-menu__drawer">
              <ul role="list" class="cursor-pointer">
                <li
                  class={[
                    "flex justify-between items-center pb-1 hover:bg-default",
                    (@comment.deleted_at || !@current_user) && "btn-disabled"
                  ]}
                  phx-click={@current_user && !@comment.deleted_at && JS.push("edit_comment")}
                  phx-target={@myself}
                >
                  <div class="flex space-x-1 items-center p-2">
                    <span class="icon-post-edit"></span>
                    <span class="text-sm">Edit</span>
                  </div>
                </li>
                <li
                  class={[
                    "flex justify-between items-center hover:bg-default",
                    (@comment.deleted_at || !@current_user) && "btn-disabled"
                  ]}
                  phx-click={
                    @current_user && !@comment.deleted_at &&
                      JS.push("delete", value: %{id: @comment.id}) |> hide("##{@id}")
                  }
                  phx-target={@myself}
                  data-confirm={@current_user && !@comment.deleted_at && "Are you sure?"}
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
      <div
        :if={@show_replies || @is_replying}
        class="flex flex-row justify-start text-sm items-center mt-3"
      >
        <div style={"margin-left: #{3 * (@level + 1)}px;"}></div>
        <section class="w-full">
          <ul>
            <li :if={@is_replying}>
              <.live_component
                module={DiscussWeb.PostLive.CommentComponent}
                id={"comment-#{@comment.id}-new-reply"}
                comment={nil}
                parent_comment_id={@comment.id}
                is_editing={@is_replying}
                level={@level + 1}
              />
            </li>
            <li :for={reply <- @replies}>
              <.live_component
                module={DiscussWeb.PostLive.CommentComponent}
                id={"reply-#{reply.id}"}
                comment={reply}
                parent_comment_id={@comment.id}
                level={@level + 1}
                current_user={@current_user}
                on_delete={
                  &send_update(DiscussWeb.PostLive.CommentComponent, id: @id, deleted_comment: &1)
                }
              />
            </li>
          </ul>
        </section>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     assign(
       socket,
       is_replying: false,
       replies: [],
       show_replies: false,
       level: if(socket.assigns[:level], do: socket.assigns.level, else: 0),
       is_editing: false,
       content: if(socket.assigns[:comment], do: socket.assigns.comment.content, else: ""),
       voted_up: false,
       voted_down: false,
       parent_comment_id: nil,
       on_delete: if(socket.assigns[:on_delete], do: socket.assigns.on_delete, else: nil),
       score: nil
     )}
  end

  @impl true
  def update(%{comment: comment} = assigns, socket) do
    changeset = Topics.change_comment(comment || %Discuss.Topics.Comment{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       voted_up: comment && comment.user_voted == :upvote,
       voted_down: comment && comment.user_voted == :downvote
     )
     |> assign_form(changeset)}
  end

  @impl true
  def update(%{deleted_comment: _child_comment}, socket) do
    %{comment: comment, current_user: current_user} = socket.assigns
    replies = Topics.get_replies_for_comment(comment.id, current_user && current_user.id)

    {:ok, socket |> assign(replies: replies)}
  end

  @impl true
  def handle_event("show_replies", _value, socket) do
    %{current_user: current_user, comment: comment} = socket.assigns

    replies = Topics.get_replies_for_comment(comment.id, current_user && current_user.id)

    {:noreply,
     assign(socket,
       show_replies: !socket.assigns.show_replies,
       replies: replies
     )}
  end

  @impl true
  def handle_event(_event_name, _value, %{assigns: %{current_user: nil}} = socket) do
    {:noreply, redirect(socket, to: ~p"/users/log_in")}
  end

  @impl true
  def handle_event("cancel_comment", _, socket) do
    notify_parent("cancel_comment")

    {:noreply,
     socket
     |> assign_form(Topics.change_comment(%Comment{}))
     |> assign(is_editing: false)
     |> assign(content: "")}
  end

  @impl true
  def handle_event("validate", %{"comment" => comment_params}, socket) do
    changeset =
      %Comment{}
      |> Topics.change_comment(comment_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign_form(changeset) |> assign(content: comment_params["content"])}
  end

  @impl true
  def handle_event("show_comment_textarea", _value, socket) do
    {:noreply, assign(socket, is_editing: !socket.assigns.is_editing)}
  end

  @impl true
  def handle_event("upvote", _value, socket) do
    mode = if socket.assigns.voted_up, do: :neutral, else: :upvote

    case Topics.add_vote_comment(%{
           mode: mode,
           comment_id: socket.assigns.comment.id,
           user_id: socket.assigns.current_user.id
         }) do
      {:ok, _} ->
        %{score: score} = Topics.get_comment_score(socket.assigns.comment.id)

        {:noreply,
         assign(
           socket,
           voted_up: !socket.assigns.voted_up,
           voted_down: false,
           score: score
         )}

      _ ->
        {:noreply, socket |> put_flash(:error, "Error upvoting comment")}
    end
  end

  @impl true
  def handle_event("downvote", _value, socket) do
    mode = if socket.assigns.voted_down, do: :neutral, else: :downvote

    case Topics.add_vote_comment(%{
           mode: mode,
           comment_id: socket.assigns.comment.id,
           user_id: socket.assigns.current_user.id
         }) do
      {:ok, _} ->
        %{score: score} = Topics.get_comment_score(socket.assigns.comment.id)

        {:noreply,
         assign(
           socket,
           voted_down: !socket.assigns.voted_down,
           voted_up: false,
           score: score
         )}

      _ ->
        {:noreply, socket |> put_flash(:error, "Error downvoting comment")}
    end
  end

  @impl true
  def handle_event("edit_comment", _value, socket) do
    {:noreply, assign(socket, is_editing: !socket.assigns.is_editing)}
  end

  @impl true
  def handle_event("save_comment", _, socket) do
    notify_parent(%{
      content: socket.assigns.content,
      id: (socket.assigns[:comment] && socket.assigns.comment.id) || nil,
      parent_id: socket.assigns.parent_comment_id || nil
    })

    {:noreply, socket}
  end

  @impl true
  def handle_event("reply_comment", _, socket) do
    {:noreply, assign(socket, is_replying: !socket.assigns.is_replying)}
  end

  @impl true
  def handle_event("delete", %{"id" => comment_id}, socket) do
    comment = Topics.get_comment!(comment_id)

    socket.assigns.on_delete &&
      socket.assigns.on_delete.(comment)

    {:ok, _} = Topics.delete_comment(comment)

    {:noreply, socket}
  end

  defp assign_form(socket, form) do
    assign(socket, :form, to_form(form))
  end

  defp resolve_color(level) do
    case rem(level, 3) do
      0 -> "red"
      1 -> "green"
      _ -> "blue"
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
