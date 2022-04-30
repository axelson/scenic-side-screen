import Config

# Generate these keys with `mix phx.gen.secret`
config :livebook, LivebookWeb.Endpoint,
  secret_key_base: "<SNIP>"

config :govee_phx, GoveePhxWeb.Endpoint,
  secret_key_base: "<SNIP>"

config :play_web, PlayWeb.Endpoint,
  secret_key_base: "<SNIP>"

config :piano_ui,
  calendar_urls: ["<SNIP>"]

config :livebook,
  password: "<SNIP>",
  node: {:longnames, :"<NAME>@<IP>"}
