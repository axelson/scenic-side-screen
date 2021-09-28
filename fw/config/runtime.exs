import Config

config :livebook,
  file_systems: [Livebook.FileSystem.Local.new(default_path: "/data/livebooks/")]
