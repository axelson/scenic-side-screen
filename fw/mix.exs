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
      strip_beams: Mix.env() == :prod or [keep: ["Docs", "Dbgi"]]
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
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Part of the application
      dep(:govee, :github),
      dep(:govee_phx, :github),
      dep(:govee_semaphore, :github),
      dep(:launcher, :github),
      dep(:piano_ctl, :github),
      dep(:piano_ui, :github),
      dep(:play, :github),
      dep(:play_web, :github),
      dep(:pomodoro, :github),

      # Work around a probably hex bug
      # jason@jdesktop ~/d/s/fw (master)> mix deps.get
      # Resolving Hex dependencies...
      #
      # Failed to use "phoenix" (version 1.5.12) because
      #   deps/govee_phx/mix.exs requires ~> 1.6.0
      #   deps/livebook/mix.exs requires 1.5.12
      # jason@jdesktop ~/d/s/fw (master)> cat deps/livebook/mix.exs|grep :phoenix,
      #       {:phoenix, "~> 1.6"},
      {:phoenix, "1.6.0", override: true},
      {:phoenix_live_view, "0.16.4", override: true},

      # {:livebook, "~> 0.2.0", only: [:dev, :prod]},
      {:livebook, github: "axelson/livebook", branch: "phx-1.6", only: [:dev, :prod]},
      # For livebook
      {:vega_lite, ">= 0.0.0"},
      {:kino, ">= 0.0.0"},
      #{:elixir_make, github: "axelson/elixir_make", branch: "detect-compile-needed", override: true},

      # Supporting
      {:boundary, "~> 0.8.0"},
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: :dev, runtime: false},
      {:nerves, "~> 1.6", runtime: false, targets: @all_targets},
      {:nerves_pack, "~> 0.4", targets: @all_targets},
      {:nerves_runtime, "~> 0.6", targets: @all_targets},
      {:nerves_system_rpi3, "~> 1.17", runtime: false, targets: :rpi3},
      # Needed for semi-accurate time for SSL certificates (for requests made by elixir-slack in pomodoro)
      {:nerves_time, "~> 0.2"},
      {:ramoops_logger, "~> 0.3.0"},
      # {:ring_logger, "~> 0.4"},
      {:ring_logger, github: "axelson/ring_logger", branch: "blame-exceptions", override: true},
      # {:ring_logger, path: "deps/ring_logger", override: true},
      {:scenic, github: "boydm/scenic", branch: "input_and_drivers", override: true},
      {:scenic_driver_local, github: "ScenicFramework/scenic_driver_local", targets: @all_targets},
      {:shoehorn, "~> 0.4"},
      {:toolshed, "~> 0.2"},
      dep(:blue_heron, :hex),
      dep(:blue_heron_transport_uart, :hex)
    ]
    |> List.flatten()
  end

  defp dep(:launcher, :path), do: {:launcher, path: "../../launcher", override: true}
  defp dep(:launcher, :github), do: {:launcher, github: "axelson/scenic_launcher"}

  defp dep(:play, :path), do: {:play, path: "../../play", override: true}

  defp dep(:play, :github),
    do: {:play, github: "axelson/scenic_asteroids", sparse: "play", branch: "js-multiplayer2", override: true}

  defp dep(:play_web, :path), do: {:play_web, path: "../../play_web", override: true}

  defp dep(:play_web, :github),
    do: {:play_web, github: "axelson/scenic_asteroids", sparse: "play_web", branch: "js-multiplayer2"}

  defp dep(:pomodoro, :github), do: {:pomodoro, github: "axelson/pomodoro", sparse: "pomodoro"}
  defp dep(:pomodoro, :path), do: {:pomodoro, path: "../../pomodoro/pomodoro", override: true}

  defp dep(:piano_ui, :github), do: {:piano_ui, github: "axelson/piano_ex", sparse: "piano_ui"}
  defp dep(:piano_ui, :path), do: {:piano_ui, path: "~/dev/piano_ex/piano_ui", override: true}

  defp dep(:piano_ctl, :github) do
    {:piano_ctl, github: "axelson/piano_ex", sparse: "piano_ctl", override: true, runtime: false}
  end

  defp dep(:piano_ctl, :path),
    do: {:piano_ctl, path: "~/dev/piano_ex/piano_ctl", override: true, runtime: false}

  defp dep(:govee, :github), do: {:govee, github: "axelson/govee"}
  defp dep(:govee, :path), do: {:govee, path: "../../govee", override: true}

  defp dep(:govee_phx, :github), do: {:govee_phx, github: "axelson/govee_phx"}
  defp dep(:govee_phx, :path), do: {:govee_phx, path: "../../govee_phx"}

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
