defmodule Papa.Visit.Fulfill do
  alias Papa.{Account, Repo, Visit}

  def call(visit, pal, args) do
    with {:fulfilled, false} <- fulfilled?(visit),
         {:ok, visit} <- update_visit(visit, pal, args) do
      # TODO: figure out how to make this atomic,
      # or rollback fist operation on failure of second operation
      Account.debit(visit.member_id, visit.minutes)
      Account.credit(visit.pal_id, visit.minutes)
      {:ok, visit}
    else
      {:fulfilled, true} -> {:error, "Visit Already Fulfilled"}
      {:error, error} -> {:error, error}
    end
  end

  defp update_visit(visit, pal, args) do
    args = Map.put(args, :pal_id, pal.id)

    changeset = Visit.changeset(visit, args)

    case Repo.update(changeset) do
      {:ok, visit} -> {:ok, visit}
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp fulfilled?(visit), do: {:fulfilled, !is_nil(visit.pal_id)}
end
