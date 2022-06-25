defmodule Papa.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Papa.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Papa.PubSub}
      # Start a worker by calling: Papa.Worker.start_link(arg)
      # {Papa.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Papa.Supervisor)
  end
end
