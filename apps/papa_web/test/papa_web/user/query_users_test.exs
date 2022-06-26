defmodule PapaWeb.QueryUsersTest do
  use PapaWeb.ConnCase

  import Papa.Factory

  alias Papa.Account

  @user_query """
  query queryUsers {
    users {
      balance
      email
      first_name
      id
      last_name
      requested_visits {
        date
        minutes
        tasks
      }
      fulfilled_visits {
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
             "balance" => 1000,
             "email" => user_1.email,
             "first_name" => user_1.first_name,
             "id" => user_1.id,
             "last_name" => user_1.last_name,
             "fulfilled_visits" => [],
             "requested_visits" => []
           }
  end

  # ---------------------------------------------------------------------------
  # Setup
  # ---------------------------------------------------------------------------

  def users(_) do
    user_1 = insert(:user, first_name: "user", last_name: "one", email: "user.one@papa.com")
    account(user_1.id)

    user_2 = insert(:user, first_name: "user", last_name: "two", email: "user.two@papa.com")
    account(user_2.id)

    %{users: [user_1, user_2]}
  end

  def account(id) do
    opts = [user_id: id, name: Account.via(id)]

    start_supervised({Account, opts}, id: id)

    Account.get_balance(id)
  end
end
