defmodule Papa.VisitSumTest do
  use Papa.DataCase

  import Papa.Factory

  alias Papa.Visit

  test "returns 0, not nil, if no visits" do
    assert Visit.Sum.call(:minutes) == 0
  end

  describe "with visits present" do
    setup [:visits]

    test "can sum up a member's minutes", ctx do
      assert Visit.Sum.call(:minutes, where: [member_id: ctx.member.id]) == 12
    end
  end

  # ---------------------------------------------------------------------------
  # Setup
  # ---------------------------------------------------------------------------

  def visits(_) do
    member = insert(:user)
    other_member = insert(:user)
    pal = insert(:user)

    visits = [
      insert(:visit, member_id: member.id, pal_id: pal.id, minutes: 1),
      insert(:visit, member_id: member.id, pal_id: pal.id, minutes: 1),
      insert(:visit, member_id: member.id, pal_id: pal.id, minutes: 2),
      insert(:visit, member_id: member.id, pal_id: pal.id, minutes: 3),
      insert(:visit, member_id: member.id, pal_id: pal.id, minutes: 5),
      insert(:visit, member_id: member.id)
    ]

    # to make sure we can filter out someone else's visits
    insert(:visit, member_id: other_member.id, pal_id: pal.id, minutes: 100)

    %{member: member, visits: visits}
  end
end
