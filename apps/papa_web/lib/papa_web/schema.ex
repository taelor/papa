defmodule PapaWeb.Schema do
  use Absinthe.Schema

  import_types(PapaWeb.Schema.User)

  query do
    import_fields(:users_queries)
  end

  mutation do
    import_fields(:users_mutations)
  end
end
