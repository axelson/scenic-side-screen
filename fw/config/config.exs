# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.

config :nerves, :firmware,
  rootfs_overlay: "rootfs_overlay",
  fwup_conf: "config/fwup.conf"

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

config :nerves,
  erlinit: [
    hostname_pattern: "nerves-%s"
  ]

# Use Ringlogger as the logger backend and remove :console.
# See https://hexdocs.pm/ring_logger/readme.html for more information on
# configuring ring_logger.

config :logger,
  backends: [RamoopsLogger, RingLogger],
  handle_otp_reports: true,
  handle_sasl_reports: true

config :blue_heron, log_hci_dump_file: false

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
    #{"usb0", %{type: VintageNetDirect}},
    {"eth0",
     %{
       type: VintageNetEthernet,
       ipv4: %{method: :dhcp}
     }},
    #{"wlan0", %{type: VintageNetWiFi}}
  ]

config :mdns_lite,
  # The `host` key specifies what hostnames mdns_lite advertises.  `:hostname`
  # advertises the device's hostname.local. For the official Nerves systems, this
  # is "nerves-<4 digit serial#>.local".  mdns_lite also advertises
  # "nerves.local" for convenience. If more than one Nerves device is on the
  # network, delete "nerves" from the list.

  host: [:hostname, "nerves"],
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
    {"asteroids", "Asteroids", {Play.Scene.Splash, Play.Scene.Asteroids}},
    {"pomodoro", "Pomodoro", {PomodoroUi.Scene.Main, nil}},
    {"piano_ui", "Piano UI", {PianoUi.Scene.Splash, nil}}
  ]

ctl_node =
  case System.get_env("CTL_NODE") do
    nil -> nil
    node -> String.to_atom(node)
  end

config :fw, nodes: [:"ctl@192.168.1.4", :"ctl@192.168.1.6"]

config :ui, ecto_repos: [PianoUi.Repo]
config :piano_ui, :ctl_node, ctl_node
# config :piano_ui, libcluster_hosts: [ctl_node]
config :piano_ui, libcluster_hosts: [:"ctl@192.168.1.4", :"ctl@192.168.1.6"]
config :piano_ui, :album_cache_dir, System.tmp_dir!() <> "/piano_ex_album_art/"

config :piano_ui, PianoUi.Repo,
  database: "/data/piano_ui_database.db",
  journal_mode: :wal,
  cache_size: -64000,
  temp_store: :memory,
  pool_size: 1


# TODO: Can we configure something else here? Maybe the launcher itself?
# Actually need to ensure that play is not reading from these configs
config :play, :viewport, %{
  size: {800, 480},
  # default_scene: {Play.Scene.Splash, Play.Scene.Asteroids},
  default_scene: {Launcher.Scene.Home, nil},
  drivers: [
    %{
      module: Scenic.Driver.Nerves.Rpi
    },
    %{
      module: Scenic.Driver.Nerves.Touch,
      opts: [
        device: "FT5406 memory based driver",
        calibartion: {{1, 0, 0}, {1, 0, 0}}
      ]
    }
  ]
}

config :phoenix, :json_library, Jason

config :govee_phx, GoveePhxWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "o3BDCy1862hqmkdyE7tMMrZDoUfLfty5U8JJXDEvmCAWj8ZqIUZmmuEmqxX5jBCv",
  render_errors: [view: GoveePhxWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: GoveePhx.PubSub,
  live_view: [signing_salt: "3J2S31Z1"],
  check_origin: false,
  server: true

config :govee_phx, GoveePhxWeb.Endpoint,
  http: [port: 80],
  url: [host: System.get_env("NODE_HOST"), port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :govee_phx,
  govee_ble_devices: [
    [
      type: :h6001,
      addr: 0xA4C138EC49BD
    ],
    [
      type: :h6001,
      addr: 0xA4C1385184DA
    ],
    [
      type: :h6159,
      addr: 0xA4C138668E6F
    ]
  ]

config :govee_phx,
  transport_config: %{
    device: "ttyAMA0",
    uart_opts: [speed: 115_200]
  },
  transport_type: :uart


# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

# import_config "#{Mix.target()}.exs"
