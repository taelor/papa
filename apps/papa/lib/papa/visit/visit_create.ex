defmodule Papa.Visit.Create do
  alias Papa.{Account, Repo}

  def call(user, args) do
    case Account.get_balance(user.id) > 0 do
      true -> insert_visit(user, args)
      false -> {:error, "Member has no minutes left to request visits"}
    end
  end

  defp insert_visit(user, args) do
    Ecto.build_assoc(user, :requested_visits, args)
    |> Repo.insert()
  end
end
