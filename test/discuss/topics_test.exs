defmodule Discuss.TopicsTest do
  use Discuss.DataCase

  alias Discuss.Topics

  describe "posts" do
    alias Discuss.Topics.Post

    import Discuss.TopicsFixtures

    @invalid_attrs %{title: nil, body: nil, slug: nil}

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Topics.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Topics.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{title: "some title", body: "some body", slug: "some slug"}

      assert {:ok, %Post{} = post} = Topics.create_post(valid_attrs)
      assert post.title == "some title"
      assert post.body == "some body"
      assert post.slug == "some slug"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Topics.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      update_attrs = %{title: "some updated title", body: "some updated body", slug: "some updated slug"}

      assert {:ok, %Post{} = post} = Topics.update_post(post, update_attrs)
      assert post.title == "some updated title"
      assert post.body == "some updated body"
      assert post.slug == "some updated slug"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Topics.update_post(post, @invalid_attrs)
      assert post == Topics.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Topics.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Topics.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Topics.change_post(post)
    end
  end
end
