defmodule PapaWeb.Schema.UserResolver do
  use Absinthe.Schema.Notation

  alias Papa.User

  def query_users(_args, _context) do
    {:ok, User.Query.call()}
  end

  def create_user(_parent, args, _context) do
    case User.Create.call(args) do
      {:ok, user} -> {:ok, user}
      {:error, changeset} -> {:error, format_errors(changeset.errors)}
    end
  end

  defp format_errors(errors) do
    Enum.map(errors, fn {field, {message, _}} -> "#{field} #{message}" end)
  end
end
