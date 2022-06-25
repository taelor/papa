defmodule PapaWeb.Schema.Visit do
  use Absinthe.Schema.Notation

  alias PapaWeb.Schema.VisitResolver

  object :visit do
    field(:id, :id)
    field(:minutes, :integer)
    field(:tasks, :string)
  end

  object :visits_mutations do
    field :request_visit, type: :visit do
      arg(:date, non_null(:string))
      arg(:tasks, non_null(:string))
      arg(:member_id, non_null(:string))

      resolve(&VisitResolver.request_visit/3)
    end
  end
end
