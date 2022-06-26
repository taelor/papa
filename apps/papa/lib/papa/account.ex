defmodule Papa.Account do
  use GenServer

  alias Papa.Visit

  @fee 0.15

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

  def credit(user_id, minutes) do
    case where(user_id) do
      {:ok, pid} -> GenServer.call(pid, {:credit, minutes})
      {:error, :not_found} -> {:error, :no_account_server}
    end
  end

  def debit(user_id, minutes) do
    case where(user_id) do
      {:ok, pid} -> GenServer.call(pid, {:debit, minutes})
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

  def handle_call({:credit, minutes}, _from, state) do
    new_balance = (state.balance + minutes * fee()) |> round()

    {:reply, new_balance, Map.put(state, :balance, new_balance)}
  end

  def handle_call({:debit, minutes}, _from, state) do
    new_balance = state.balance - minutes

    {:reply, new_balance, Map.put(state, :balance, new_balance)}
  end

  @impl true
  def handle_continue(:ledger_balance, %{user_id: id} = state) do
    balance = 1000 + sum_credit(id) - sum_debit(id)

    {:noreply, Map.put(state, :balance, balance)}
  end

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  def sum_credit(id), do: (Visit.Sum.call(:minutes, where: [pal_id: id]) * fee()) |> round()
  def sum_debit(id), do: Visit.Sum.call(:minutes, where: [member_id: id])

  def fee(), do: 1 - @fee
end
