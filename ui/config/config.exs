use Mix.Config

# Disable tzdata automatic updates
config :tzdata, :autoupdate, :disabled
config :phoenix, :json_library, Jason

config :logger, :console, format: "$time $metadata[$level] $levelpad$message\n"

# Configure the main viewport for the Scenic application
config :play, :viewport, %{
  name: :main_viewport,
  size: {800, 480},
  # default_scene: {Timer.Scene.Home, nil},
  # default_scene: {Play.Scene.Asteroids, nil},
  # default_scene: {Play.Scene.Splash, Play.Scene.Asteroids},
  default_scene: {Launcher.Scene.Home, nil},
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      name: :glfw,
      opts: [resizeable: false, title: "play"]
    }
  ]
}

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
  transport_config: %{
    vid: 0x0A5C,
    pid: 0x21E8
  },
  transport_type: :usb

case Mix.env() do
  :dev ->
    config :exsync,
      reload_timeout: 75,
      reload_callback: {GenServer, :call, [ScenicLiveReload, :reload_current_scene]}

  _ ->
    nil
end

import_config "#{Mix.env()}.exs"
