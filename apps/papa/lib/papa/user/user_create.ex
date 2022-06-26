defmodule Papa.User.Create do
  alias Papa.Repo

  alias Papa.User

  # TODO: better error handling
  def call(args) do
    with {:ok, user} <- create(args) do
      Papa.AccountSupervisor.start_child(user.id)

      {:ok, user}
    else
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp create(args) do
    User.changeset(%User{}, args)
    |> Repo.insert()
  end
end
