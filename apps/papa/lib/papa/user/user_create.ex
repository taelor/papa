defmodule Papa.User.Create do
  alias Papa.Repo

  alias Papa.User

  def call(args) do
    User.changeset(%User{}, args)
    |> Repo.insert()
  end
end
