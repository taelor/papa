defmodule PapaWeb.RequestVisitTest do
  use PapaWeb.ConnCase

  import Papa.Factory

  setup [:user, :query]

  test "request visit", %{conn: conn} = ctx do
    conn = post(conn, "/api", %{"query" => ctx.query})

    %{"data" => %{"requestVisit" => visit}} = json_response(conn, 200)

    assert is_binary(visit["id"])
    assert visit["tasks"] == "Just hang out"
  end

  # ---------------------------------------------------------------------------
  # Setup
  # ---------------------------------------------------------------------------

  def user(_), do: %{user: insert(:user, email: "test.user@papa.com")}

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
