defmodule PapaWeb.Schema do
  use Absinthe.Schema

  import_types(PapaWeb.Schema.User)

  query do
    import_fields(:get_users)
  end
end
