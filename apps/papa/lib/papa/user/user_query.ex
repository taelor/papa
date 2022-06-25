defmodule Papa.User.Query do
  import Ecto.Query

  alias Papa.Repo
  alias Papa.User

  def call(opts) do
    preloads = Keyword.get(opts, :preloads, [])

    User
<<<<<<< HEAD
<<<<<<< HEAD
    |> preload(^preloads)
=======
    |> preload(:visits)
>>>>>>> 7a325b1 (adding visits schema, relationship to user, add to graphql user query)
=======
    |> preload(^preloads)
>>>>>>> e441d19 (small premature optomization, only preload when necessary)
    |> Repo.all()
  end
end
