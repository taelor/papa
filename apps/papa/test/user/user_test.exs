defmodule Papa.UserTest do
  use Papa.DataCase

  import Papa.Factory

  alias Papa.User

  describe "a changeset with invalid data" do
    setup [:invalid_attrs]

    test "returns error changeset", ctx do
      changeset = User.changeset(%User{}, ctx.attrs)

      refute changeset.valid?
    end
  end

  describe "a changeset with valid data" do
    setup [:valid_attrs]

    test "returns valid changeset", ctx do
      changeset = User.changeset(%User{}, ctx.attrs)

      assert changeset.valid?
    end
  end

  describe "with existing user" do
    setup [:valid_attrs, :user]

    test "validates unique email", ctx do
      {:error, changeset} = User.changeset(%User{}, ctx.attrs) |> Repo.insert()

      assert changeset.errors == [
               email:
                 {"has already been taken",
                  [constraint: :unique, constraint_name: "users_email_index"]}
             ]
    end
  end

  # ---------------------------------------------------------------------------
  # Setup
  # ---------------------------------------------------------------------------

  def invalid_attrs(_) do
    %{attrs: %{}}
  end

  def valid_attrs(_) do
    %{attrs: %{first_name: "Jane", last_name: "Doe", email: "jdoe@papa.com"}}
  end

  def user(ctx), do: %{user: insert(:user, ctx.attrs)}
end
