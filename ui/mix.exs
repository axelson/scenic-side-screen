defmodule Ui.MixProject do
  use Mix.Project

  def project do
    [
      app: :ui,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "1.0.0", only: :dev, runtime: false},
      dep(:phoenix_live_reload, :github),
      dep(:play, :github),
      dep(:launcher, :github),
      dep(:piano_ui, :github),
      dep(:piano_ctl, :github),
      {:scenic, "~> 0.10"},
      {:scenic_driver_glfw, "~> 0.10"},
      dep(:scenic_live_reload, :hex),
      dep(:pomodoro, :github)
    ]
    |> List.flatten()
  end

  defp dep(:launcher, :path), do: {:launcher, path: "../../launcher", override: true}
  defp dep(:launcher, :github), do: {:launcher, github: "axelson/scenic_launcher"}

  defp dep(:phoenix_live_reload, :path),
    do: {:phoenix_live_reload, path: "../../forks/phoenix_live_reload", only: :dev}

  defp dep(:phoenix_live_reload, :github), do: {:phoenix_live_reload, "~> 1.2", only: :dev}

  defp dep(:play, :path), do: {:play, path: "../../scenic_asteroids/play", override: true}

  defp dep(:play, :github),
    do: {:play, github: "axelson/scenic_asteroids", sparse: "play", branch: "js-multiplayer"}

  defp dep(:pomodoro, :github), do: {:pomodoro, github: "axelson/pomodoro"}
  defp dep(:pomodoro, :path), do: {:pomodoro, path: "../../pomodoro"}

  defp dep(:scenic_live_reload, :hex), do: {:scenic_live_reload, "~> 0.1", only: :dev}

  defp dep(:scenic_live_reload, :github),
    do: {:scenic_live_reload, github: "axelson/scenic_live_reload", only: :dev}

  defp dep(:scenic_live_reload, :path),
    do: {:scenic_live_reload, path: "../../scenic_live_reload", only: :dev}

  defp dep(:piano_ui, :github), do: {:piano_ui, github: "axelson/piano_ex", sparse: "piano_ui"}
  defp dep(:piano_ui, :path), do: {:piano_ui, path: "~/dev/piano_ex/piano_ui"}

  defp dep(:piano_ctl, :github) do
    {:piano_ctl, github: "axelson/piano_ex", sparse: "piano_ctl", override: true, runtime: false}
  end
end
