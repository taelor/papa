defmodule PapaWeb.RequestVisitTest do
  use PapaWeb.ConnCase

  import Papa.Factory

  test "request visit", %{conn: conn} do
    conn = post(conn, "/api", %{"query" => @user_query})

    %{"data" => %{"requestVisit" => visit}} = json_response(conn, 200)

    assert is_binary(user["id"])
    assert user["last_tasks"] == "Just hang out"
  end

  # ---------------------------------------------------------------------------
  # Setup
  # ---------------------------------------------------------------------------

  def user(_), do: %{user: insert(:user, email: "test.user@papa.com")}

  def query(ctx) do
    """
    mutation requestVisit {
      requestVisit(date: "2020-07-01", tasks: "Just hang out", memberId:"#{ctx.user.id}"){
        id
        tasks
      }
    }
    """
  end
end
