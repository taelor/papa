defmodule Papa.User.Query do
  alias Papa.Repo

  alias Papa.User

  def call() do
    User
    |> Repo.all()
  end
end
