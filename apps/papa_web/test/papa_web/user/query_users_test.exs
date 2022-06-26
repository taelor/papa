defmodule PapaWeb.QueryUsersTest do
  use PapaWeb.ConnCase

  import Papa.Factory

  @user_query """
  query queryUsers {
    users {
      email
      first_name
      id
      last_name
      visits {
        date
        minutes
        tasks
      }
    }
  }
  """

  setup [:users]

  test "query: user", %{conn: conn} = ctx do
    [user_1 | _] = ctx.users

    conn = post(conn, "/api", %{"query" => @user_query})

    %{"data" => %{"users" => users}} = json_response(conn, 200)

    assert Enum.count(users) == 2

    assert Enum.at(users, 0) == %{
             "email" => user_1.email,
             "first_name" => user_1.first_name,
             "id" => user_1.id,
             "last_name" => user_1.last_name,
             "visits" => []
           }
  end

  # ---------------------------------------------------------------------------
  # Setup
  # ---------------------------------------------------------------------------

  def users(_) do
    user_1 = insert(:user, first_name: "user", last_name: "one", email: "user.one@papa.com")
    user_2 = insert(:user, first_name: "user", last_name: "two", email: "user.two@papa.com")

    %{users: [user_1, user_2]}
  end
end
