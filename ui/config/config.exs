use Mix.Config

# Disable tzdata automatic updates
config :tzdata, :autoupdate, :disabled
config :phoenix, :json_library, Jason

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

config :logger, :console, format: "$time $metadata[$level] $levelpad$message\n"
# config :logger, :console, format: "[$level] $message\n"

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

case Mix.env() do
  :dev ->
    config :exsync,
      reload_timeout: 75,
      reload_callback: {GenServer, :call, [ScenicLiveReload, :reload_current_scene]}

  _ ->
    nil
end
