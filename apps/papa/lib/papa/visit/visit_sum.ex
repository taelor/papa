defmodule Papa.Visit.Sum do
  import Ecto.Query

  alias Papa.Repo
  alias Papa.Visit

  def call(column, opts \\ []) do
    conds = Keyword.get(opts, :where, [])

    case Visit |> where(^conds) |> Repo.aggregate(:sum, column) do
      nil -> 0
      sum -> sum
    end
  end
end
