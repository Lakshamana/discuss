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

  describe "comments" do
    alias Discuss.Topics.Comment

    import Discuss.TopicsFixtures

    @invalid_attrs %{content: nil, deleted_at: nil}

    test "list_comments/0 returns all comments" do
      comment = comment_fixture()
      assert Topics.list_comments() == [comment]
    end

    test "get_comment!/1 returns the comment with given id" do
      comment = comment_fixture()
      assert Topics.get_comment!(comment.id) == comment
    end

    test "create_comment/1 with valid data creates a comment" do
      valid_attrs = %{content: "some content", deleted_at: ~U[2024-02-01 14:40:00Z]}

      assert {:ok, %Comment{} = comment} = Topics.create_comment(valid_attrs)
      assert comment.content == "some content"
      assert comment.deleted_at == ~U[2024-02-01 14:40:00Z]
    end

    test "create_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Topics.create_comment(@invalid_attrs)
    end

    test "update_comment/2 with valid data updates the comment" do
      comment = comment_fixture()
      update_attrs = %{content: "some updated content", deleted_at: ~U[2024-02-02 14:40:00Z]}

      assert {:ok, %Comment{} = comment} = Topics.update_comment(comment, update_attrs)
      assert comment.content == "some updated content"
      assert comment.deleted_at == ~U[2024-02-02 14:40:00Z]
    end

    test "update_comment/2 with invalid data returns error changeset" do
      comment = comment_fixture()
      assert {:error, %Ecto.Changeset{}} = Topics.update_comment(comment, @invalid_attrs)
      assert comment == Topics.get_comment!(comment.id)
    end

    test "delete_comment/1 deletes the comment" do
      comment = comment_fixture()
      assert {:ok, %Comment{}} = Topics.delete_comment(comment)
      assert_raise Ecto.NoResultsError, fn -> Topics.get_comment!(comment.id) end
    end

    test "change_comment/1 returns a comment changeset" do
      comment = comment_fixture()
      assert %Ecto.Changeset{} = Topics.change_comment(comment)
    end
  end
end
