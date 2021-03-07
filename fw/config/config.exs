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
  init: [:nerves_runtime, :nerves_init_gadget],
  app: Mix.Project.config()[:app]

# Use Ringlogger as the logger backend and remove :console.
# See https://hexdocs.pm/ring_logger/readme.html for more information on
# configuring ring_logger.

config :logger,
  backends: [RamoopsLogger, RingLogger],
  handle_otp_reports: true,
  handle_sasl_reports: true

config :blue_heron, log_hci_dump_file: false

# Authorize the device to receive firmware using your public key.
# See https://hexdocs.pm/nerves_firmware_ssh/readme.html for more information
# on configuring nerves_firmware_ssh.

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

config :nerves_firmware_ssh,
  authorized_keys: authorized_keys

# Configure nerves_init_gadget.
# See https://hexdocs.pm/nerves_init_gadget/readme.html for more information.

config :nerves_init_gadget,
  ifname: "eth0",
  address_method: :dhcp,
  node_name: "murphy",
  node_host: System.get_env("NODE_HOST")

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

config :piano_ui, :ctl_node, ctl_node
config :piano_ui, libcluster_hosts: [ctl_node]
config :piano_ui, :album_cache_dir, System.tmp_dir!() <> "/piano_ex_album_art/"
config :piano_ui, ecto_repos: [PianoUi.Repo]

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
