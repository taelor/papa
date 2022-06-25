defmodule Papa.User.Query do
  import Ecto.Query

  alias Papa.Repo
  alias Papa.User

  def call(opts) do
    preloads = Keyword.get(opts, :preloads, [])

    User
<<<<<<< HEAD
    |> preload(^preloads)
=======
    |> preload(:visits)
>>>>>>> 7a325b1 (adding visits schema, relationship to user, add to graphql user query)
    |> Repo.all()
  end
end
