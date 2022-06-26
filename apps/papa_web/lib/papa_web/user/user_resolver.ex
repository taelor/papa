defmodule PapaWeb.Schema.UserResolver do
  use Absinthe.Schema.Notation

  alias Papa.User

  def query_users(_args, resolution) do
    {:ok, User.Query.call(preloads: preloads(resolution))}
  end

  defp preloads(resolution) do
    # might be better to get this from the ecto schema instead.
    associations = MapSet.new([:requested_visits, :fulfilled_visits])

    # get the fields requested from the graphql api request
    requested_fields =
      resolution.definition.selections
      |> Enum.map(& &1.schema_node.identifier)
      |> MapSet.new()

    MapSet.intersection(associations, requested_fields) |> MapSet.to_list()
  end

  def create_user(_parent, args, _resolution) do
    case User.Create.call(args) do
      {:ok, user} -> {:ok, user}
      {:error, changeset} -> {:error, format_errors(changeset.errors)}
    end
  end

  defp format_errors(errors) do
    Enum.map(errors, fn {field, {message, _}} -> "#{field} #{message}" end)
  end
end
