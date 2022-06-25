defmodule PapaWeb.Schema.User do
  use Absinthe.Schema.Notation

  alias PapaWeb.Schema.UserResolver

  object :user do
    field(:id, :id)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
  end

  object :users_queries do
    field :users, list_of(:user) do
      resolve(&UserResolver.query_users/2)
    end
  end

  object :users_mutations do
    field :create_user, type: :user do
      arg(:first_name, non_null(:string))
      arg(:last_name, non_null(:string))
      arg(:email, non_null(:string))

      resolve(&UserResolver.create_user/3)
    end
  end
end
