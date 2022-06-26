defmodule Papa.AccountSupervisor do
  use DynamicSupervisor

  alias Papa.User

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_children() do
    User.Query.call()
    |> Enum.each(fn user ->
      start_child(user.id)
    end)

    :ok
  end

  def start_child(user_id) do
    opts = [
      user_id: user_id,
      name: Papa.Account.via(user_id)
    ]

    spec = {Papa.Account, opts}

    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
