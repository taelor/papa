defmodule Papa.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Papa.Repo
  alias Papa.Visit

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field(:email, :string)
    field(:first_name, :string)
    field(:last_name, :string)

    has_many(:visits, Visit, foreign_key: :member_id)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email])
    |> validate_required([:first_name, :last_name, :email])
    |> unique_constraint(:email)
  end

  def get(nil), do: nil
  def get(""), do: nil
  def get(id), do: Repo.get(__MODULE__, id)
end
