use Mix.Config

# Disable tzdata automatic updates
config :tzdata, :autoupdate, :disabled
config :phoenix, :json_library, Jason

config :logger, :console, format: "$time $metadata[$level] $levelpad$message\n"

config :scenic, :assets, module: Ui.Assets

config :ui, :viewport,
  name: :main_viewport,
  size: {800, 480},
  default_scene: {Launcher.Scene.Home, nil},
  drivers: [
    [
      module: Scenic.Driver.Local,
      window: [
        title: "My Scenic Companion"
      ]
    ]
  ]

config :govee_phx, GoveePhxWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "o3BDCy1862hqmkdyE7tMMrZDoUfLfty5U8JJXDEvmCAWj8ZqIUZmmuEmqxX5jBCv",
  render_errors: [view: GoveePhxWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: GoveePhx.PubSub,
  live_view: [signing_salt: "3J2S31Z1"]

config :launcher, refresh_enabled: true

config :launcher,
  scenes: [
    {"asteroids", "Asteroids", {Play.Scene.Splash, Play.Scene.Asteroids}},
    {"pomodoro", "Pomodoro", {PomodoroUi.Scene.Main, pomodoro_timer_pid: Pomodoro.PomodoroTimer}},
    {"piano_ui", "Piano UI", {PianoUi.Scene.Splash, pomodoro_timer_pid: Pomodoro.PomodoroTimer}}
  ]

ctl_node =
  case System.get_env("CTL_NODE") do
    nil -> nil
    node -> String.to_atom(node)
  end

config :ui, ecto_repos: [PianoUi.Repo]

config :piano_ui, PianoUi.Repo,
  database: "/Users/jason/dev/scenic-side-screen/ui/piano_ui_database.db",
  journal_mode: :wal,
  cache_size: -64000,
  temp_store: :memory,
  pool_size: 1

config :play,
  viewport_size: {800, 480},
  phx_endpoint: PlayWeb.Endpoint

config :play_web, PlayWeb.Endpoint,
  url: [host: "localhost"],
  reloadable_apps: [:play, :play_ui, :play_web],
  server: true,
  secret_key_base: "4m4EdLqbm138oXxQyvWMUy8CEiksqoNBPjoHZEwvhnGVML9SrFNCXtE57z6x8EV1",
  render_errors: [view: PlayWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: PlayWeb.PubSub

config :piano_ui, :ctl_node, ctl_node
config :piano_ui, libcluster_hosts: [ctl_node]
config :piano_ui, :album_cache_dir, System.tmp_dir!() <> "/piano_ex_album_art/"

config :piano_ctl, libcluster_hosts: []

config :govee_phx,
  govee_ble_devices: [
    #[
    #  type: :h6001,
    #  addr: 0xA4C138EC49BD
    #],
    #[
    #  type: :h6001,
    #  addr: 0xA4C1385184DA
    #],
    #[
    #  type: :h6159,
    #  addr: 0xA4C138668E6F
    #]
  ]

config :govee_phx,
  # transport_config: %{
  #   vid: 0x0A5C,
  #   pid: 0x21E8
  # },
  # transport_type: :usb
  transport_type: :disabled

case Mix.env() do
  :dev ->
    config :exsync,
      reload_timeout: 75,
      reload_callback: {GenServer, :call, [ScenicLiveReload, :reload_current_scene]}

  _ ->
    nil
end

import_config "#{Mix.env()}.exs"
