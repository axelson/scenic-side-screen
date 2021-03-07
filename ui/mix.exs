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
      mod: {UiApplication, []},
      extra_applications: [:sasl, :logger]
    ]
  end

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
      dep(:pomodoro, :github),
      {:exsync, path: "~/dev/forks/exsync", override: true},
      {:exqlite, github: "warmwaffles/exqlite", ref: "60d365e46", override: true},

      # Supporting
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: :dev, runtime: false},
      dep(:phoenix_live_reload, :hex),
      {:scenic, "~> 0.10"},
      {:scenic_driver_glfw, "~> 0.10"},
      dep(:scenic_live_reload, :hex),
      dep(:blue_heron, :github),
      dep(:blue_heron_transport_usb, :github)
    ]
    |> List.flatten()
  end

  defp dep(:launcher, :path), do: {:launcher, path: "../../launcher", override: true}
  defp dep(:launcher, :github), do: {:launcher, github: "axelson/scenic_launcher"}

  defp dep(:phoenix_live_reload, :hex), do: {:phoenix_live_reload, "~> 1.2"}

  defp dep(:phoenix_live_reload, :path),
    do: {:phoenix_live_reload, path: "../../forks/phoenix_live_reload", only: :dev}

  defp dep(:phoenix_live_reload, :github), do: {:phoenix_live_reload, "~> 1.2", only: :dev}

  defp dep(:play, :path), do: {:play, path: "../../scenic_asteroids/play", override: true}

  defp dep(:play, :github),
    do: {:play, github: "axelson/scenic_asteroids", sparse: "play", branch: "js-multiplayer"}

  defp dep(:pomodoro, :github), do: {:pomodoro, github: "axelson/pomodoro"}
  defp dep(:pomodoro, :path), do: {:pomodoro, path: "../../pomodoro", override: true}

  defp dep(:govee, :github), do: {:govee, github: "axelson/govee"}
  defp dep(:govee, :path), do: {:govee, path: "../../govee", override: true}

  defp dep(:govee_phx, :github), do: {:govee_phx, github: "axelson/govee_phx"}
  defp dep(:govee_phx, :path), do: {:govee_phx, path: "../../govee_phx"}

  defp dep(:govee_semaphore, :github), do: {:govee_semaphore, github: "axelson/govee_semaphore"}

  defp dep(:govee_semaphore, :path),
    do: {:govee_semaphore, path: "../../govee_semaphore", override: true}

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
  defp dep(:piano_ctl, :path), do: {:piano_ctl, path: "~/dev/piano_ex/piano_ctl"}

  defp dep(:blue_heron, :hex), do: {:blue_heron, ">= 0.0.0"}

  defp dep(:blue_heron, :github),
    do: {:blue_heron, github: "smartrent/blue_heron", branch: "main", sparse: "blue_heron", override: true}

  defp dep(:blue_heron, :path),
    do: {:blue_heron, path: "~/dev/forks/blue_heron/blue_heron", override: true}

  defp dep(:blue_heron_transport_usb, :hex), do: {:blue_heron_transport_usb, ">= 0.0.0"}

  defp dep(:blue_heron_transport_usb, :github),
    do:
      {:blue_heron_transport_usb,
       github: "smartrent/blue_heron",
       branch: "main",
       sparse: "blue_heron_transport_usb"}

  defp dep(:blue_heron_transport_usb, :path),
    do: {:blue_heron_transport_usb, path: "~/dev/forks/blue_heron/blue_heron_transport_usb"}
end
