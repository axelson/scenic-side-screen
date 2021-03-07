use Mix.Config

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :ui, ecto_repos: [PianoUi.Repo]

config :piano_ui, PianoUi.Repo,
  database: "priv/database.db",
  journal_mode: :wal,
  cache_size: -64_000,
  temp_store: :memory,
  pool_size: 1

config :govee_phx, GoveePhxWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  #code_reloader: true,
  check_origin: false
  #watchers: [
  #  node: [
  #    "node_modules/webpack/bin/webpack.js",
  #    "--mode",
  #    "development",
  #    "--watch-stdin",
  #    # Might need to make this configurable based on the dependency type
  #    cd: Path.expand("~/dev/govee_phx/assets", __DIR__)
  #    #cd: Path.expand("../deps/govee_phx/assets", __DIR__)
  #  ]
  #]

#config :govee_phx, GoveePhxWeb.Endpoint,
#  live_reload: [
#    patterns: [
#      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
#      ~r"priv/gettext/.*(po)$",
#      ~r"~/dev/govee_phx/lib/govee_phx_web/(live|views)/.*(ex)$",
#      #~r"../deps/govee_phx/lib/govee_phx_web/(live|views)/.*(ex)$",
#      ~r"lib/govee_phx_web/templates/.*(eex)$"
#    ]
#  ],
#  reloadable_apps: [:govee, :govee_phx, :notes, :launcher]
