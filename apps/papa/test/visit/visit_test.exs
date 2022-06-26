defmodule Papa.VisitTest do
  use Papa.DataCase

  import Papa.Factory

  alias Papa.Visit

  describe "a changeset with invalid data" do
    setup [:invalid_attrs]

    test "returns error changeset", ctx do
      changeset = Visit.changeset(%Visit{}, ctx.attrs)

      refute changeset.valid?
    end
  end

  describe "a changeset with valid data" do
    setup [:member, :valid_attrs]

    test "returns valid changeset", ctx do
      changeset = Visit.changeset(%Visit{}, ctx.attrs)

      assert changeset.valid?
    end
  end

  describe "when a pal fulfills their own visit" do
    setup [:member, :visit]

    test "returns invalid changeset", ctx do
      changeset = Visit.changeset(ctx.visit, %{pal_id: ctx.member.id})

      assert changeset.errors == [pal_id: {"A pal cannot fullfill their own request", []}]
    end
  end

  # ---------------------------------------------------------------------------
  # Setup
  # ---------------------------------------------------------------------------

  def member(_), do: %{member: insert(:user)}

  def invalid_attrs(_) do
    %{attrs: %{}}
  end

  def valid_attrs(ctx) do
    %{attrs: %{member_id: ctx.member.id, date: Date.utc_today(), minutes: 100, tasks: "tasks"}}
  end

  def visit(ctx), do: %{visit: insert(:visit, member_id: ctx.member.id)}
end
