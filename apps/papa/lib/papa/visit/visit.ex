defmodule Papa.Visit do
  use Ecto.Schema
  import Ecto.Changeset

  alias Papa.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "visits" do
    field(:date, :date)
    field(:minutes, :integer)
    field(:tasks, :string)

    belongs_to(:member, User)
    belongs_to(:pal, User)

    timestamps()
  end

  @doc false
  def changeset(visit, attrs) do
    visit
    |> cast(attrs, [:date, :minutes, :tasks, :member_id, :pal_id])
    |> validate_required([:date, :tasks, :member_id])
    |> validate_not_self_fulfilling()

    # probably need to prevent minutes if not fulfilled by pal
    # |> validate_no_minutes_if_no_pal()
  end

  def validate_not_self_fulfilling(changeset) do
    validate_change(changeset, :pal_id, fn :pal_id, pal_id ->
      member_id = get_field(changeset, :member_id)

      case !!member_id && !!pal_id && member_id == pal_id do
        true -> [{:pal_id, "A pal cannot fullfill their own request"}]
        false -> []
      end
    end)
  end

  def get(nil), do: nil
  def get(""), do: nil
  def get(id), do: Repo.get(__MODULE__, id)
end
