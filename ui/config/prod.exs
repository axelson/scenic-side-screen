import Config

# Do not print debug messages in production
config :logger, level: :info

config :govee_phx, GoveePhxWeb.Endpoint,
  url: [port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

