defmodule PapaWeb.Router do
  use PapaWeb, :router

  pipeline :graphql do
  end

  scope "/api" do
    pipe_through :graphql

    forward "/", Absinthe.Plug, schema: PapaWeb.Schema
  end

  if Mix.env() == :dev do
    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: PapaWeb.Schema
  end
end
