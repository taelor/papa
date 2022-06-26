defmodule PapaWeb.FulfillVisitTest do
  use PapaWeb.ConnCase

  import Papa.Factory

  alias Papa.Account

  setup [:member, :pal, :visit, :query]

  test "fulfill visit", %{conn: conn} = ctx do
    conn = post(conn, "/api", %{"query" => ctx.query})

    %{"data" => %{"fulfillVisit" => visit}} = json_response(conn, 200)

    assert is_binary(visit["id"])
    assert visit["minutes"] == 100

    assert Account.get_balance(ctx.member.id) == 900
    assert Account.get_balance(ctx.pal.id) == 1085
  end

  # ---------------------------------------------------------------------------
  # Setup
  # ---------------------------------------------------------------------------

  def member(_), do: setup_user(:member)
  def pal(_), do: setup_user(:pal)
  def visit(ctx), do: %{visit: insert(:visit, member_id: ctx.member.id)}

  def query(ctx) do
    query = """
    mutation fulfillVisit {
      fulfillVisit(visitId:"#{ctx.visit.id}" ,palId:"#{ctx.pal.id}", minutes: 100){
        id
        minutes
      }
    }
    """

    %{query: query}
  end

  defp setup_user(side) do
    user = insert(:user)

    opts = [user_id: user.id, name: Account.via(user.id)]

    start_supervised({Account, opts}, id: user.id)

    Account.get_balance(user.id)

    Map.new([{side, user}])
  end
end
