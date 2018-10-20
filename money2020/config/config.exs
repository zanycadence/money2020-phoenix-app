# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :money2020,
  ecto_repos: [Money2020.Repo]

# Configures the endpoint
config :money2020, Money2020Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "kc/lu/WLOzwtqWsT2NGP1ARYDc7M1M1sSQODhg5pDeUElLZqI+diJ9wo4sHBlNU/",
  render_errors: [view: Money2020Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Money2020.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
