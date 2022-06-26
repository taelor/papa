defmodule Papa.AccountTest do
  use Papa.DataCase

  import Papa.Factory

  alias Papa.Account

  describe("when Account server initializes ") do
    setup [:member, :pal, :visits, :account]

    test "It ledgers a user's balance", ctx do
      assert Account.get_balance(ctx.member.id) == 900
    end
  end

  # ---------------------------------------------------------------------------
  # Setup
  # ---------------------------------------------------------------------------

  def member(_), do: %{member: insert(:user)}
  def pal(_), do: %{pal: insert(:user)}

  def visits(ctx) do
    visits = [
      insert(:visit, member_id: ctx.member.id, pal_id: ctx.pal.id, minutes: 100)
    ]

    %{visits: visits}
  end

  def account(ctx) do
    opts = [
      user_id: ctx.member.id,
      name: Papa.Account.via(ctx.member.id)
    ]

    start_supervised({Account, opts})
    :ok
  end
end
