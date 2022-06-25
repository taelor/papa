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

User.changeset(%User{}, %{first_name: "John", last_name: "Doe", email: "john.doe@papa.com"})
|> Repo.insert!()

User.changeset(%User{}, %{first_name: "Jane", last_name: "Doe", email: "jane.doe@papa.com"})
|> Repo.insert!()

User.changeset(%User{}, %{first_name: "Papa", last_name: "Pal", email: "papa.pal@papa.com"})
|> Repo.insert!()
