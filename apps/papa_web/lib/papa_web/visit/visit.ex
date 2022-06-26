defmodule PapaWeb.Schema.Visit do
  use Absinthe.Schema.Notation

  alias PapaWeb.Schema.VisitResolver

  object :visit do
    field(:id, :id)
    field(:date, :string)
    field(:minutes, :integer)
    field(:tasks, :string)
  end

  object :visits_mutations do
    field :request_visit, type: :visit do
      arg(:date, non_null(:string))
      arg(:tasks, non_null(:string))
      arg(:member_id, non_null(:id))

      resolve(&VisitResolver.request_visit/3)
    end

    field :fulfill_visit, type: :visit do
      arg(:visit_id, non_null(:id))
      arg(:minutes, non_null(:integer))
      arg(:pal_id, non_null(:id))

      resolve(&VisitResolver.fulfill_visit/3)
    end
  end
end
