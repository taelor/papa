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

requested_visits = [
  %{date: Date.utc_today(), tasks: "Play cards, Clean ceiling fan"},
  %{date: Date.add(Date.utc_today(), 15), tasks: "Play cards, help take care of garden"}
]

user_john =
  User.changeset(%User{}, %{first_name: "John", last_name: "Doe", email: "john.doe@papa.com"})
  |> Repo.insert!()

Enum.each(visits, fn visit ->
  Ecto.build_assoc(user_john, :visits, requested_visits)
  |> Repo.insert!()
end)

user_jane =
  User.changeset(%User{}, %{first_name: "Jane", last_name: "Doe", email: "jane.doe@papa.com"})
  |> Repo.insert!()

Enum.each(visits, fn visit ->
  Ecto.build_assoc(user_jane, :visits, requested_visits)
  |> Repo.insert!()
end)

User.changeset(%User{}, %{first_name: "Papa", last_name: "Pal", email: "papa.pal@papa.com"})
|> Repo.insert!()
