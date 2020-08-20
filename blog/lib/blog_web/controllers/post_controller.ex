defmodule BlogWeb.PostController do
  use BlogWeb, :controller

  alias Blog.Pages
  alias Blog.Pages.Post
  alias Blog.Accounts

  plug :check_auth when action in [:new, :create, :edit, :update, :delete]

  def index(conn, _params) do
    posts = Pages.list_posts()
    render(conn, "index.html", posts: posts)
  end

  def new(conn, _params) do
    changeset = Pages.change_post(%Post{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    case Pages.create_post(post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Pages.get_post!(id)
    render(conn, "show.html", post: post)
  end

  def edit(conn, %{"id" => id}) do
    post = Pages.get_post!(id)
    changeset = Pages.change_post(post)
    render(conn, "edit.html", post: post, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Pages.get_post!(id)

    case Pages.update_post(post, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Pages.get_post!(id)
    {:ok, _post} = Pages.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: Routes.post_path(conn, :index))
  end

  defp check_auth(conn, _args) do
    if (user_id = get_session(conn, :current_user_id)) && Accounts.get_username(user_id) == "david" do
      current_user = Accounts.get_user!(user_id)

      conn
      |> assign(:current_user, current_user)
    else
      conn
      |> put_flash(:error, "You are not authorized to create or edit blog posts")
      |> redirect(to: Routes.post_path(conn, :index))
      |> halt()
    end
  end
end
