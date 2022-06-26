defmodule Papa.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: Papa.Repo

  def user_factory do
    %Papa.User{
      first_name: "Jane",
      last_name: "Smith",
      email: sequence(:email, &"email-#{&1}@papa.com")
    }
  end

  def visit_factory do
    %Papa.Visit{
      date: Date.utc_today(),
      tasks: "Play cards, help garden"
    }
  end
end
