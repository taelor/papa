defmodule Papa.Visit do
  use Ecto.Schema
  import Ecto.Changeset

  alias Papa.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "visits" do
    field :date, :date
    field :minutes, :integer
    field :tasks, :string

    belongs_to :member, User

    timestamps()
  end

  @doc false
  def changeset(visit, attrs) do
    visit
    |> cast(attrs, [:date, :minutes, :tasks, :member_id])
    |> validate_required([:date, :tasks, :member_id])
  end
end
