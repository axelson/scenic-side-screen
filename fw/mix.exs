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
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "1.0.0-rc.7", only: :dev, runtime: false},
      dep(:launcher, :github),
      {:nerves, "~> 1.5", runtime: false, targets: @all_targets},
      {:nerves_firmware_ssh, ">= 0.0.0", targets: @all_targets},
      {:nerves_init_gadget, "~> 0.4", targets: @all_targets},
      {:nerves_runtime, "~> 0.6", targets: @all_targets},
      {:nerves_system_rpi3, "~> 1.8", runtime: false, targets: :rpi3},
      # Needed for semi-accurate time for SSL certificates (for requests made by elixir-slack in timer)
      {:nerves_time, "~> 0.2"},
      dep(:play, :github),
      {:ramoops_logger, "~> 0.3.0"},
      {:ring_logger, "~> 0.4"},
      {:scenic_driver_nerves_rpi, "0.10.0", targets: @all_targets},
      {:scenic_driver_nerves_touch, "0.10.0", targets: @all_targets},
      {:shoehorn, "~> 0.4"},
      dep(:timer, :github),
      {:toolshed, "~> 0.2"}
    ]
    |> List.flatten()
  end

  defp dep(:launcher, :path), do: {:launcher, path: "../../launcher", override: true}
  defp dep(:launcher, :github), do: {:launcher, github: "axelson/scenic_launcher"}

  defp dep(:play, :path), do: {:play, path: "../../play", override: true}

  defp dep(:play, :github),
    do:
      {:play, github: "axelson/scenic_asteroids", sparse: "play", branch: "reduce-build-scripts"}

  defp dep(:timer, :path), do: {:timer, path: "../../pomodoro/timer"}

  defp dep(:timer, :github) do
    # Use two sparse deps to same repository to work around:
    # https://groups.google.com/forum/#!topic/elixir-lang-core/cSjjCLcr-YQ
    # NOTE: Ensure that they both reference the same commit
    [
      {:timer, git: "https://github.com/axelson/pomodoro.git", sparse: "timer"},
      {:timer_core,
       git: "https://github.com/axelson/pomodoro.git", sparse: "timer_core", override: true}
    ]
  end
end
