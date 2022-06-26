defmodule Papa.User.Query do
  import Ecto.Query

  alias Papa.Repo
  alias Papa.User

  def call(opts \\ []) do
    preloads = Keyword.get(opts, :preloads, [])

    User
    |> preload(^preloads)
    |> Repo.all()
  end
end
