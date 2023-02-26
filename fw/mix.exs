defmodule Fw.MixProject do
  use Mix.Project

  @all_targets [:rpi3]
  @app :fw

  def project do
    [
      app: @app,
      version: "0.1.0",
      elixir: "~> 1.6",
      archives: [nerves_bootstrap: "~> 1.6"],
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.target() != :host,
      aliases: [loadconfig: [&bootstrap/1]],
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host]
    ]
  end

  def release do
    [
      overwrite: true,
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod or [keep: ["Docs", "Dbgi"]],
      config_providers: [{Fw.RuntimeConfigProvider, "/data/.target.secret.exs"}]
    ]
  end

  # Starting nerves_bootstrap adds the required aliases to Mix.Project.config()
  # Aliases are only added if MIX_TARGET is set.
  def bootstrap(args) do
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Fw.Application, []},
      extra_applications: [:logger, :ssh, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Part of the application
      dep(:govee, :github),
      # dep(:govee_scenic, :github),
      dep(:govee_phx, :github),
      dep(:govee_semaphore, :github),
      dep(:launcher, :github),
      dep(:piano_ctl, :github),
      dep(:piano_ui, :github),
      dep(:play, :github),
      dep(:play_web, :github),
      dep(:pomodoro, :github),

      {:phoenix, "~> 1.6.7"},
      # {:phoenix_live_view, "~> 0.18.7"},
      # {:phoenix_live_view, "0.17.12"},
      # https://github.com/hexpm/hex/issues/972
      {:phoenix_live_view, "0.18.11", override: true},

      # https://github.com/hexpm/hex/issues/972
      {:phoenix_live_dashboard, "0.7.2", override: true},

      {:telemetry_poller, "~> 1.0"},

      # {:ssh_client_key_api, path: "~/dev/forks/ssh_client_key_api"},
      {:ssh_client_key_api, github: "axelson/ssh_client_key_api", branch: "support-erlang-otp-25"},

      # {:keylight, github: "lawik/keylight"},
      # Waiting on https://github.com/lawik/keylight/pull/2
      {:keylight, github: "axelson/keylight", branch: "minor-updates"},
      # {:keylight, path: "~/dev/forks/keylight"},

      # Waiting on https://github.com/nerves-networking/mdns_lite/pull/98
      # {:mdns_lite, github: "axelson/mdns_lite", branch: "add_get_by_mdns", override: true},

      # {:livebook, "~> 0.5.2", only: [:dev, :prod]},
      {:livebook, github: "axelson/livebook", only: [:dev, :prod]},
      # {:livebook, path: "~/dev/forks/livebook", only: [:dev, :prod]},
      # For livebook
      {:vega_lite, ">= 0.0.0"},
      {:kino, ">= 0.0.0"},
      {:power_control, "~> 0.2.0"},
      {:rpi_fb_capture, "~> 0.3.0", targets: @all_targets},
      #{:elixir_make, github: "axelson/elixir_make", branch: "detect-compile-needed", override: true},

      # {:pinout, "~> 0.1"},
      # {:pinout, path: "~/dev/forks/pinout"},
      {:pinout, github: "axelson/pinout", branch: "add-rpi-3b-plus-files"},
      {:master_proxy, github: "axelson/master_proxy", branch: "flexiblity-1"},

      # Supporting
      {:boundary, "~> 0.9"},
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: :dev, runtime: false},
      {:nerves, "~> 1.9", runtime: false, targets: @all_targets},
      {:nerves_pack, "~> 0.4", targets: @all_targets},
      {:nerves_runtime, "~> 0.6", targets: @all_targets},
      {:circuits_gpio, "~> 1.0 or ~> 0.4", targets: @all_targets},
      {:nerves_system_rpi3, "~> 1.17", runtime: false, targets: :rpi3},
      # Needed for semi-accurate time for SSL certificates (for requests made by elixir-slack in pomodoro)
      {:nerves_time, "~> 0.2"},
      {:ramoops_logger, "~> 0.3.0"},
      # {:ring_logger, "~> 0.4"},
      {:ring_logger, github: "axelson/ring_logger", branch: "blame-exceptions", override: true},
      # {:ring_logger, path: "deps/ring_logger", override: true},
      # {:scenic, github: "boydm/scenic", branch: "input_and_drivers", override: true},
      # {:scenic, github: "boydm/scenic", branch: "v0.11", override: true},

      # {:scenic, github: "boydm/scenic", override: true},
      {:scenic, "~> 0.11"},
      {:scenic_driver_local, "~> 0.11"},

      # {:scenic, path: "~/dev/forks/scenic", override: true},
      # {:scenic_driver_local, github: "ScenicFramework/scenic_driver_local", targets: @all_targets},

      # {:scenic_driver_local, path: "deps/scenic_driver_local", targets: @all_targets},
      {:shoehorn, "~> 0.4"},
      {:toolshed, "~> 0.2"},
      dep(:blue_heron, :github),
      dep(:blue_heron_transport_uart, :hex)
    ]
    |> List.flatten()
  end

  defp dep(:launcher, :path), do: {:launcher, path: "../../launcher", override: true}
  defp dep(:launcher, :github), do: {:launcher, github: "axelson/scenic_launcher"}

  defp dep(:play, :path), do: {:play, path: "../../scenic_asteroids/play", override: true}

  defp dep(:play, :github),
    do: {:play, github: "axelson/scenic_asteroids", sparse: "play", branch: "js-multiplayer2", override: true}

  defp dep(:play_web, :path), do: {:play_web, path: "../../scenic_asteroids/play_web", override: true}

  defp dep(:play_web, :github),
    do: {:play_web, github: "axelson/scenic_asteroids", sparse: "play_web", branch: "js-multiplayer2"}

  defp dep(:pomodoro, :github), do: {:pomodoro, github: "axelson/pomodoro"}
  defp dep(:pomodoro, :path), do: {:pomodoro, path: "../../pomodoro", override: true}

  defp dep(:piano_ui, :github), do: {:piano_ui, github: "axelson/piano_ex", sparse: "piano_ui"}
  defp dep(:piano_ui, :path), do: {:piano_ui, path: "~/dev/piano_ex/piano_ui", override: true}

  defp dep(:piano_ctl, :github) do
    {:piano_ctl, github: "axelson/piano_ex", sparse: "piano_ctl", override: true, runtime: false}
  end

  defp dep(:piano_ctl, :path),
    do: {:piano_ctl, path: "~/dev/piano_ex/piano_ctl", override: true, runtime: false}

  defp dep(:govee, :github), do: {:govee, github: "axelson/govee", branch: "new-update"}
  defp dep(:govee, :path), do: {:govee, path: "../../govee", override: true}

  defp dep(:govee_phx, :github), do: {:govee_phx, github: "axelson/govee_phx"}
  defp dep(:govee_phx, :path), do: {:govee_phx, path: "../../govee_phx"}

  defp dep(:govee_scenic, :github), do: {:govee_scenic, github: "axelson/govee_scenic"}
  defp dep(:govee_scenic, :path), do: {:govee_scenic, path: "../../govee_scenic"}

  defp dep(:govee_semaphore, :github), do: {:govee_semaphore, github: "axelson/govee_semaphore"}

  defp dep(:govee_semaphore, :path),
    do: {:govee_semaphore, path: "../../govee_semaphore", override: true}

  defp dep(:blue_heron, :hex), do: {:blue_heron, ">= 0.0.0", override: true}

  defp dep(:blue_heron, :github),
    do: {:blue_heron, github: "blue-heron/blue_heron", branch: "main", override: true}

  defp dep(:blue_heron, :github_rpi3),
    do: {:blue_heron, github: "axelson/blue_heron", branch: "rpi3-fix", override: true}

  defp dep(:blue_heron, :path),
    do: {:blue_heron, path: "~/dev/forks/blue_heron", override: true}

  defp dep(:blue_heron_transport_uart, :hex), do: {:blue_heron_transport_uart, ">= 0.0.0"}

  defp dep(:blue_heron_transport_uart, :github),
    do:
      {:blue_heron_transport_uart, github: "blue-heron/blue_heron_transport_uart", branch: "main"}

  defp dep(:blue_heron_transport_uart, :path),
    do: {:blue_heron_transport_uart, path: "~/dev/forks/blue_heron_transport_uart"}
end
