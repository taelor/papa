defmodule Papa.Account do
  use GenServer

  alias Papa.Visit

  def start_link(opts) do
    {name, opts} = Keyword.pop(opts, :name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @impl true
  def init(user_id: user_id) do
    {:ok, %{user_id: user_id}, {:continue, :ledger_balance}}
  end

  def name(id), do: {Account.Registry, id}
  def via(id), do: {:via, Registry, name(id)}

  def where(id) do
    case Registry.lookup(Account.Registry, id) do
      [{pid, _}] -> {:ok, pid}
      [] -> {:error, :not_found}
    end
  end

  # ---------------------------------------------------------------------------
  # Client
  # ---------------------------------------------------------------------------

  def get_balance(user_id) do
    # Here, I would like to implement a "locate or start" pattern,
    # where we could start the Account server if its not found,
    # which would ledger the balance, and return it.

    # this get rid of the need of starting an account server for every
    # single User on the application boot, and only start it on demand.
    case where(user_id) do
      {:ok, pid} -> GenServer.call(pid, :get_balance)
      {:error, :not_found} -> {:error, :no_account_server}
    end
  end

  # ---------------------------------------------------------------------------
  # Server
  # ---------------------------------------------------------------------------

  @impl true
  def handle_call(:get_balance, _from, state) do
    {:reply, state.balance, state}
  end

  @impl true
  def handle_continue(:ledger_balance, %{user_id: id} = state) do
    balance = 1000 - debit(id) + credit(id)

    {:noreply, Map.put(state, :balance, balance)}
  end

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  def debit(id), do: Visit.Sum.call(:minutes, where: [member_id: id])
  def credit(id), do: (Visit.Sum.call(:minutes, where: [pal_id: id]) * 0.85) |> round()
end
