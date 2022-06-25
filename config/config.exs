# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Configure Mix tasks and generators
config :papa,
  ecto_repos: [Papa.Repo]

config :papa_web,
  ecto_repos: [Papa.Repo],
  generators: [context_app: :papa, binary_id: true]

# Configures the endpoint
config :papa_web, PapaWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: PapaWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Papa.PubSub,
  live_view: [signing_salt: "iStOk2zr"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
