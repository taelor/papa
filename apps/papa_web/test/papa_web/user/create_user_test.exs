defmodule PapaWeb.CreateUsersTest do
  use PapaWeb.ConnCase, async: false

  alias Papa.Repo

  import Papa.Factory

  @user_query """
  mutation createUser {
    createUser(first_name: "test", last_name: "user", email: "test.user@papa.com"){
      email
      first_name
      id
      last_name
    }
  }
  """

  # since we dynamically create a GenServer on creating a user,
  # we can't explictly allow the sandbox to that pid, so we have
  # to run in shared mode.
  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    :ok
  end

  test "create user", %{conn: conn} do
    conn = post(conn, "/api", %{"query" => @user_query})

    %{"data" => %{"createUser" => user}} = json_response(conn, 200)

    assert user["email"] == "test.user@papa.com"
    assert user["first_name"] == "test"
    assert is_binary(user["id"])
    assert user["last_name"] == "user"
  end

  describe "when email already exists" do
    setup [:user]

    test "query: user", %{conn: conn} do
      conn = post(conn, "/api", %{"query" => @user_query})

      %{"data" => %{"createUser" => nil}, "errors" => errors} = json_response(conn, 200)

      assert Enum.at(errors, 0)["message"] == "email has already been taken"
    end
  end

  # ---------------------------------------------------------------------------
  # Setup
  # ---------------------------------------------------------------------------

  def user(_), do: %{user: insert(:user, email: "test.user@papa.com")}
end
