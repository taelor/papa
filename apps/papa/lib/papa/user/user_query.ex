defmodule Papa.User.Query do
  import Ecto.Query

  alias Papa.Repo
  alias Papa.User

  def call() do
    User
    |> preload(:visits)
    |> Repo.all()
  end
end
