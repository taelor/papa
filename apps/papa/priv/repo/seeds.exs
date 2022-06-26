# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Papa.Repo.insert!(%Papa.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Papa.Repo

alias Papa.User

user_john =
  User.changeset(%User{}, %{first_name: "John", last_name: "Doe", email: "john.doe@papa.com"})
  |> Repo.insert!()

user_jane =
  User.changeset(%User{}, %{first_name: "Jane", last_name: "Doe", email: "jane.doe@papa.com"})
  |> Repo.insert!()

user_polly =
  User.changeset(%User{}, %{first_name: "Polly", last_name: "Pal", email: "polly.pal@papa.com"})
  |> Repo.insert!()

user_perry =
  User.changeset(%User{}, %{first_name: "Perry", last_name: "Pal", email: "perry.pal@papa.com"})
  |> Repo.insert!()


john_fulfilled_visits = [
  %{date: Date.utc_today(), tasks: "Play cards, Clean ceiling fan", minutes: 100, pal_id: user_polly.id},
  %{date: Date.utc_today(), tasks: "Help in Garden", minutes: 50, pal_id: user_perry.id},
]

Enum.each(john_fulfilled_visits, fn visit ->
  Ecto.build_assoc(user_john, :requested_visits, visit) |> Repo.insert!()
end)

jane_fulfilled_visits = [
  %{date: Date.utc_today(), tasks: "Play cards, Clean ceiling fan", minutes: 100, pal_id: user_polly.id},
  %{date: Date.utc_today(), tasks: "Help in Garden", minutes: 50, pal_id: user_perry.id},
]

Enum.each(jane_fulfilled_visits, fn visit ->
  Ecto.build_assoc(user_jane, :requested_visits, visit) |> Repo.insert!()
end)
