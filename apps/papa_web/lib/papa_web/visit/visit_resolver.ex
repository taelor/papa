defmodule PapaWeb.Schema.VisitResolver do
  use Absinthe.Schema.Notation

  alias Papa.{User, Visit}

  def request_visit(_parent, args, _resolution) do
    with {:ok, date} <- parse_date(args.date),
         {:ok, user} <- get_user(args.member_id) do
      args = Map.put(args, :date, date)

      case Visit.Create.call(user, args) do
        {:ok, visit} -> {:ok, visit}
        {:error, changeset} -> {:error, format_errors(changeset.errors)}
      end
    else
      {:error, error} -> {:error, error}
    end
  end

  defp parse_date(date_string) do
    case Date.from_iso8601(date_string) do
      {:ok, date} -> {:ok, date}
      {:error, _} -> {:error, "Invalid Date"}
    end
  end

  defp get_user(id) do
    case User.get(id) do
      nil -> {:error, "Invalid User"}
      user -> {:ok, user}
    end
  end

  defp format_errors(errors) do
    Enum.map(errors, fn {field, {message, _}} -> "#{field} #{message}" end)
  end
end
