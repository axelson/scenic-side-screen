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

config :logger, RingLogger,
  buffers: %{
    low_priority: %{
      levels: [:warning, :notice, :info, :debug],
      max_size: 2048
    },
    high_priority: %{
      levels: [:emergency, :alert, :critical, :error],
      max_size: 2048
    }
  },
  metadata: [:mfa, :line],
  format: "$time $metadata[$level] $message\n"

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
    "pomodoro.#{mdns_hostname}",
    "asteroids.#{mdns_hostname}",
    "livebook.#{mdns_hostname}"
  ],
  ttl: 120,

  # Advertise the following services over mDNS.
  services: [
    %{
      protocol: "ssh",
      transport: "tcp",
      port: 22
    },
    %{
      protocol: "sftp-ssh",
      transport: "tcp",
      port: 22
    },
    %{
      protocol: "epmd",
      transport: "tcp",
      port: 4369
    }
  ],

  # Configure DNS bridge
  dns_bridge_enabled: true,
  dns_bridge_ip: {127, 0, 0, 53},
  dns_bridge_port: 53,
  # Set to `false` to avoid issues like:
  # The following arguments were given to :mdns_lite_inet_dns.encode_res_section/3:
  #
  #   # 1
  #   <<218, 163, 129, 128, 0, 1, 0, 4, 0, 0, 0, 1, 1, 48, 4, 112, 111, 111, 108, 3, 110, 116, 112, 3, 111, 114, 103, 0, 0, 1, 0, 1, 192, 12, 0, 1, 0, 1, 0, 0, 0, 58, 0, 4, 216, 31, 17, 12, 192, 12, ...>>
  #
  #   # 2
  #   {4, {["0", "pool", "ntp", "org"], 12, nil, {["pool", "ntp", "org"], 14, {["ntp", "org"], 19, nil, {["org"], 23, nil, nil}}, nil}}}
  #
  #   # 3
  #   [{:dns_rr_opt, ~c".", :opt, 512, 0, 0, 0, "", false}]
  dns_bridge_recursive: false

config :vintage_net,
  additional_name_servers: [{127, 0, 0, 53}]

config :launcher, :backlight_module, Fw.Backlight
config :launcher, :sleep_all_module, Fw.SleepAll
config :launcher, :reboot_mfa, {Nerves.Runtime, :reboot, []}

config :launcher,
  scenes: [
    {"piano_ui", "Dashboard",
     {PianoUi.Scene.Dashboard, pomodoro_timer_pid: Pomodoro.PomodoroTimer}},
    # {"pomodoro", "Pomodoro", {PomodoroUi.Scene.MiniComponent, t: {595, 69}, pomodoro_timer_pid: Pomodoro.PomodoroTimer}},
    {"pomodoro", "Pomodoro", {PomodoroUi.Scene.Main, []}},
    {"asteroids", "Asteroids", {Play.Scene.Splash, Play.Scene.Asteroids}},
    {"keylight", "Keylight", {PianoUi.KeylightScene, []}}
  ]

config :main_proxy,
  http: [:inet6, port: 80]

config :fw,
  govee_phx_domain: "govee.#{mdns_hostname}.local",
  pomodoro_phx_domain: "pomodoro.#{mdns_hostname}.local",
  asteroids_domain: "asteroids.#{mdns_hostname}.local",
  livebook_domain: "livebook.#{mdns_hostname}.local"

config :fw, ecto_repos: [PianoUi.Repo, Pomodoro.Repo]

config :play,
  viewport_size: {800, 480},
  phx_endpoint: PlayWeb.Endpoint

config :play_web, PlayWeb.Endpoint,
  url: [host: "asteroids.#{mdns_hostname}.local", port: 80],
  reloadable_apps: [:play, :play_ui, :play_web],
  secret_key_base: "4m4EdLqbm138oXxQyvWMUy8CEiksqoNBPjoHZEwvhnGVML9SrFNCXtE57z6x8EV1",
  render_errors: [view: PlayWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: PlayWeb.PubSub,
  check_origin: ["http://asteroids.#{mdns_hostname}.local"],
  server: false

config :piano_ui, :libcluster_strategy, Cluster.Strategy.Epmd
config :piano_ui, :album_cache_dir, "/tmp/piano_ex_album_art/"
config :piano_ui, ecto_repos: [PianoUi.Repo]

config :piano_ui, PianoUi.Repo,
  database: "/data/piano_ui_database.db",
  journal_mode: :wal,
  cache_size: -64_000,
  temp_store: :memory,
  pool_size: 1

config :piano_ui, meeting_module: Fw.Meeting
config :piano_ui, keylight_module: Fw.KeylightImpl

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
  url: [host: "govee.#{mdns_hostname}.local", port: 80],
  secret_key_base: "o3BDCy1862hqmkdyE7tMMrZDoUfLfty5U8JJXDEvmCAWj8ZqIUZmmuEmqxX5jBCv",
  render_errors: [view: GoveePhxWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: GoveePhx.PubSub,
  live_view: [signing_salt: "3J2S31Z1"],
  cache_static_manifest: "priv/static/cache_manifest.json",
  check_origin: ["http://govee.#{mdns_hostname}.local"],
  server: false

config :govee_phx,
  # The devices are set in `.target.secret.exs` so that they're not defined in the repository
  govee_ble_devices: [],
  transport_config: %{
    device: "ttyS0",
    uart_opts: [speed: 115_200]
  },
  transport_type: :uart

config :pomodoro_phx, PomodoroPhxWeb.Endpoint,
  url: [host: "pomodoro.#{mdns_hostname}.local", port: 80],
  render_errors: [
    formats: [html: PomodoroPhxWeb.ErrorHTML, json: PomodoroPhxWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: PomodoroPhx.PubSub,
  live_view: [signing_salt: "63Bjta55"],
  server: false

config :fw, Dash.QuantumScheduler,
  jobs: [
    {"0 2 * * *", {Fw, :stop_for_the_night, []}}
  ]

# Livebook's explore section is built at compile-time
config :livebook, :explore_notebooks, []

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

# import_config "#{Mix.target()}.exs"
