defmodule PapaWeb.RequestVisitTest do
  use PapaWeb.ConnCase

  import Papa.Factory

  alias Papa.Account

  describe "when user has balance > 0" do
    setup [:user, :account, :query]

    test "request visit", %{conn: conn} = ctx do
      conn = post(conn, "/api", %{"query" => ctx.query})

      %{"data" => %{"requestVisit" => visit}} = json_response(conn, 200)

      assert is_binary(visit["id"])
      assert visit["tasks"] == "Just hang out"
    end
  end

  describe "when user has 0 or less balance" do
    setup [:user, :visit, :account, :query]

    test "they cannot request a visit", %{conn: conn} = ctx do
      conn = post(conn, "/api", %{"query" => ctx.query})

      %{"data" => %{"requestVisit" => nil}, "errors" => errors} = json_response(conn, 200)

      assert Enum.at(errors, 0)["message"] == "Member has no minutes left to request visits"
    end
  end

  # ---------------------------------------------------------------------------
  # Setup
  # ---------------------------------------------------------------------------

  def user(_), do: %{user: insert(:user)}

  def visit(%{user: user}) do
    %{visit: insert(:visit, member_id: user.id, pal_id: insert(:user).id, minutes: 1000)}
  end

  def account(%{user: user}) do
    # At this point, I would refactor this out into a support helper module
    opts = [user_id: user.id, name: Account.via(user.id)]

    start_supervised({Account, opts}, id: user.id)

    Account.get_balance(user.id)

    :ok
  end

  def query(ctx) do
    query = """
    mutation requestVisit {
      requestVisit(date: "2020-07-01", tasks: "Just hang out", memberId:"#{ctx.user.id}"){
        id
        tasks
      }
    }
    """

    %{query: query}
  end
end
