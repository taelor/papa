defmodule PapaWeb.Schema.UserResolver do
  use Absinthe.Schema.Notation

  alias Papa.User

  def query_users(_args, _context) do
    {:ok, User.Query.call()}
  end
end
