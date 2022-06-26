defmodule Papa.Visit.Create do
  alias Papa.Repo

  def call(user, args) do
    Ecto.build_assoc(user, :requested_visits, args)
    |> Repo.insert()
  end
end
