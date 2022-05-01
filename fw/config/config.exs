# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.

mdns_hostname = "nerves-side-screen"
config :fw, mdns_hostname: mdns_hostname

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

# Cannot write update files to a read-only file system. Plus we don't need
# accurate timezones
config :tzdata, :autoupdate, :disabled

# Use shoehorn to start the main application. See the shoehorn
# docs for separating out critical OTP applications such as those
# involved with firmware updates.

config :shoehorn,
  init: [:nerves_runtime, :nerves_pack],
  app: Mix.Project.config()[:app]

# Nerves Runtime can enumerate hardware devices and send notifications via
# SystemRegistry. This slows down startup and not many programs make use of
# this feature.

config :nerves_runtime, :kernel, use_system_registry: false

# Erlinit can be configured without a rootfs_overlay. See
# https://github.com/nerves-project/erlinit/ for more information on
# configuring erlinit.

config :nerves, :erlinit,
  hang_on_exit: true,
  run_on_exit: "/bin/sh",
  print_timing: true,
  hostname_pattern: "nerves-%s",
  shutdown_report: "/data/last_shutdown.txt"

# Use Ringlogger as the logger backend and remove :console.
# See https://hexdocs.pm/ring_logger/readme.html for more information on
# configuring ring_logger.

config :logger,
  backends: [RamoopsLogger, RingLogger]

config :blue_heron, log_hci_dump_file: false

config :scenic, :assets, module: Fw.Assets

key_paths =
  [
    ".ssh/id_rsa.pub",
    ".ssh/id_desktop_rsa.pub",
    ".ssh/id_laptop_rsa.pub",
    ".ssh/id_nerves.pub",
    ".ssh/id_air_laptop.pub"
  ]
  |> Enum.map(fn path -> Path.join(System.user_home!(), path) end)

authorized_keys =
  key_paths
  |> Enum.filter(&File.exists?/1)
  |> Enum.map(&File.read!/1)

if Enum.empty?(authorized_keys),
  do: Mix.raise("No SSH Keys found. Please generate an ssh key")

config :nerves_ssh,
  authorized_keys: authorized_keys

# Configure the network using vintage_net
# See https://github.com/nerves-networking/vintage_net for more information
config :vintage_net,
  regulatory_domain: "US",
  config: [
    # {"usb0", %{type: VintageNetDirect}},
    {"eth0",
     %{
       type: VintageNetEthernet,
       ipv4: %{method: :dhcp}
     }}
    # {"wlan0", %{type: VintageNetWiFi}}
  ]

config :mdns_lite,
  # The `host` key specifies what hostnames mdns_lite advertises.  `:hostname`
  # advertises the device's hostname.local. For the official Nerves systems, this
  # is "nerves-<4 digit serial#>.local".
  hosts: [
    :hostname,
    mdns_hostname,
    "govee.#{mdns_hostname}",
    "asteroids.#{mdns_hostname}",
    "livebook.#{mdns_hostname}"
  ],
  ttl: 120,

  # Advertise the following services over mDNS.
  services: [
    %{
      name: "SSH Remote Login Protocol",
      protocol: "ssh",
      transport: "tcp",
      port: 22
    },
    %{
      name: "Secure File Transfer Protocol over SSH",
      protocol: "sftp-ssh",
      transport: "tcp",
      port: 22
    },
    %{
      name: "Erlang Port Mapper Daemon",
      protocol: "epmd",
      transport: "tcp",
      port: 4369
    }
  ]

config :launcher, :backlight_module, Fw.Backlight
config :launcher, :reboot_mfa, {Nerves.Runtime, :reboot, []}

config :launcher,
  scenes: [
    {"piano_ui", "Dashboard",
     {PianoUi.Scene.Dashboard, pomodoro_timer_pid: Pomodoro.PomodoroTimer}},
    # {"pomodoro", "Pomodoro", {PomodoroUi.Scene.MiniComponent, t: {595, 69}, pomodoro_timer_pid: Pomodoro.PomodoroTimer}},
    {"pomodoro", "Pomodoro", {PomodoroUi.Scene.Main, []}},
    {"asteroids", "Asteroids", {Play.Scene.Splash, Play.Scene.Asteroids}}
  ]

ctl_node =
  case System.get_env("CTL_NODE") do
    nil -> nil
    node -> String.to_atom(node)
  end

config :master_proxy,
  http: [:inet6, port: 80]

config :fw,
  nodes: [ctl_node],
  govee_phx_domain: "govee.#{mdns_hostname}.local",
  asteroids_domain: "asteroids.#{mdns_hostname}.local",
  livebook_domain: "livebook.#{mdns_hostname}.local"

config :fw, ecto_repos: [PianoUi.Repo, Pomodoro.Repo]

config :play,
  viewport_size: {800, 480},
  phx_endpoint: PlayWeb.Endpoint

config :play_web, PlayWeb.Endpoint,
  http: [port: 8080],
  url: [host: "asteroids.#{mdns_hostname}.local", port: 80],
  reloadable_apps: [:play, :play_ui, :play_web],
  secret_key_base: "4m4EdLqbm138oXxQyvWMUy8CEiksqoNBPjoHZEwvhnGVML9SrFNCXtE57z6x8EV1",
  render_errors: [view: PlayWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: PlayWeb.PubSub,
  check_origin: ["http://asteroids.#{mdns_hostname}.local"],
  server: true

config :piano_ui, :libcluster_strategy, Cluster.Strategy.Epmd
config :piano_ui, :album_cache_dir, "/tmp/piano_ex_album_art/"
config :piano_ui, ecto_repos: [PianoUi.Repo]

config :piano_ui, PianoUi.Repo,
  database: "/data/piano_ui_database.db",
  journal_mode: :wal,
  cache_size: -64_000,
  temp_store: :memory,
  pool_size: 1

config :pomodoro, ecto_repos: [Pomodoro.Repo]

config :pomodoro, Pomodoro.Repo,
  database: "/data/pomodoro_database.db",
  migration_primary_key: [type: :binary_id],
  journal_mode: :wal,
  cache_size: -64_000,
  temp_store: :memory,
  pool_size: 1

config :pomodoro, sound_directory: "/data/pomodoro_sounds"

config :fw, :viewport,
  name: :main_viewport,
  size: {800, 480},
  default_scene: {Launcher.Scene.Home, nil},
  drivers: [
    [
      module: Scenic.Driver.Local
    ]
  ]

config :phoenix, :json_library, Jason

config :govee_phx, GoveePhxWeb.Endpoint,
  http: [port: 4004, transport_options: [num_acceptors: 2]],
  url: [host: "govee.#{mdns_hostname}.local", port: 80],
  secret_key_base: "o3BDCy1862hqmkdyE7tMMrZDoUfLfty5U8JJXDEvmCAWj8ZqIUZmmuEmqxX5jBCv",
  render_errors: [view: GoveePhxWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: GoveePhx.PubSub,
  live_view: [signing_salt: "3J2S31Z1"],
  cache_static_manifest: "priv/static/cache_manifest.json",
  check_origin: ["http://govee.#{mdns_hostname}.local"],
  server: true

config :govee_phx,
  # The devices are set in `.target.secret.exs` so that they're not defined in the repository
  govee_ble_devices: [],
  transport_config: %{
    device: "ttyS0",
    uart_opts: [speed: 115_200]
  },
  transport_type: :uart

# Livebook's explore section is built at compile-time
config :livebook, :explore_notebooks, []

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

# import_config "#{Mix.target()}.exs"
