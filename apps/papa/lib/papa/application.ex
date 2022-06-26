defmodule Papa.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Papa.Repo,
      Papa.AccountSupervisor,
      {Registry, keys: :unique, name: Account.Registry},
      {Task, &Papa.AccountSupervisor.start_children/0}
    ]

    Supervisor.start_link(children, strategy: :rest_for_one, name: Papa.Supervisor)
  end
end
