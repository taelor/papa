defmodule Papa.UserCreateTest do
  use Papa.DataCase

  alias Papa.{Account, User}

  describe "when a user is created" do
    test "it starts a new Account server" do
      {:ok, user} =
        User.Create.call(%{first_name: "new", last_name: "user", email: "new.user@papa.com"})

      assert Account.get_balance(user.id) == 1000
    end
  end

  # ---------------------------------------------------------------------------
  # Setup
  # ---------------------------------------------------------------------------
end
