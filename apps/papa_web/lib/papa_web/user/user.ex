defmodule PapaWeb.Schema.User do
  use Absinthe.Schema.Notation

  alias PapaWeb.Schema.UserResolver

  object :user do
    field(:id, :id)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
  end

  object :query_users do
    field :users, list_of(:user) do
      resolve(&UserResolver.query_users/2)
    end
  end
end
