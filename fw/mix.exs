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
      steps: [&Nerves.Release.init/1, :assemble]
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
      dep(:piano_ctl, :path),
      dep(:piano_ui, :path),
      dep(:play, :github),
      dep(:pomodoro, :path),
      {:livebook, "~> 0.1.0", only: [:dev, :prod]},

      # Supporting
      {:boundary, "~> 0.8.0"},
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: :dev, runtime: false},
      {:nerves, "~> 1.6", runtime: false, targets: @all_targets},
      {:nerves_pack, "~> 0.4", targets: @all_targets},
      {:nerves_runtime, "~> 0.6", targets: @all_targets},
      # Not able to update to version 1.13.2+ because I don't know how to turn
      # off the backlight
      {:nerves_system_rpi3, "1.13.0", runtime: false, targets: :rpi3},
      # Needed for semi-accurate time for SSL certificates (for requests made by elixir-slack in pomodoro)
      {:nerves_time, "~> 0.2"},
      {:ramoops_logger, "~> 0.3.0"},
      {:ring_logger, "~> 0.4"},
      # {:scenic, "0.10.3", targets: @all_targets, override: true},
      {:scenic, "0.10.3", override: true},
      {:scenic_driver_nerves_rpi, "0.10.1", targets: @all_targets},
      {:scenic_driver_nerves_touch, "0.10.0", targets: @all_targets},
      {:shoehorn, "~> 0.4"},
      {:toolshed, "~> 0.2"},
      dep(:blue_heron, :path),
      dep(:blue_heron_transport_uart, :github)
    ]
    |> List.flatten()
  end

  defp dep(:launcher, :path), do: {:launcher, path: "../../launcher", override: true}
  defp dep(:launcher, :github), do: {:launcher, github: "axelson/scenic_launcher"}

  defp dep(:play, :path), do: {:play, path: "../../play", override: true}

  defp dep(:play, :github),
    do: {:play, github: "axelson/scenic_asteroids", sparse: "play", branch: "js-multiplayer"}

  defp dep(:pomodoro, :github), do: {:pomodoro, github: "axelson/pomodoro"}
  defp dep(:pomodoro, :path), do: {:pomodoro, path: "../../pomodoro", override: true}

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

  defp dep(:blue_heron, :hex), do: {:blue_heron, ">= 0.0.0"}

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
