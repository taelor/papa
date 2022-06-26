defmodule Papa.Repo.Migrations.CreateVisits do
  use Ecto.Migration

  def change do
    create table(:visits, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:date, :date)
      add(:minutes, :integer)
      add(:tasks, :text)
      add(:member_id, references(:users, on_delete: :nothing, type: :binary_id))
      add(:pal_id, references(:users, on_delete: :nothing, type: :binary_id))

      timestamps()
    end

    create(index(:visits, [:member_id]))
    create(index(:visits, [:pal_id]))
  end
end
