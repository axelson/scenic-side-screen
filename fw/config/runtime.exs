import Config

# Start with Livebook defaults
Livebook.config_runtime()

mdns_hostname = Application.get_env(:fw, :mdns_hostname)

config :livebook,
  default_runtime: Livebook.Runtime.Embedded.new(),
  file_systems: [Livebook.FileSystem.Local.new(default_path: "/data/livebooks/")],
  iframe_port: 8081,
  app_service_name: nil,
  app_service_url: nil,
  authentication_mode: :password,
  token_authentication: false,
  cookie: :fw_cookie,
  storage: Livebook.Storage.Ets,
  shutdown_enabled: false,
  plugs: [],
  password: System.get_env("LIVEBOOK_PASSWORD", "nerves")

config :livebook, LivebookWeb.Endpoint,
  http: [
    port: 4040,
    transport_options: [socket_opts: [:inet6], num_acceptors: 2]
  ],
  secret_key_base: "CinsHrNmCwlrZlxMTWLOpgh6FQv8e61XeL/xkBRAYqhh8VEOvCAPZqap2KoKolKB",
  pubsub_server: Livebook.PubSub,
  live_view: [signing_salt: "livebook"],
  check_origin: ["http://livebook.#{mdns_hostname}.local"],
  code_reloader: false,
  server: true

