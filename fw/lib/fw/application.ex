defmodule Fw.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @target Mix.Project.config()[:target]
  # @all_targets [:rpi0, :rpi3, :rpi]

  use Application

  def start(_type, _args) do
    Fw.Livebook.initialize_data_directory()
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Fw.Supervisor]
    Supervisor.start_link(children(@target), opts)
  end

  # List all child processes to be supervised
  def children("host") do
    [
      # Starts a worker by calling: Fw.Worker.start_link(arg)
      # {Fw.Worker, arg},
    ]
  end

  def children(_target) do
    main_viewport_config = Application.get_env(:fw, :viewport)

    [
      {Scenic, [main_viewport_config]},
      # Starts a worker by calling: Fw.Worker.start_link(arg)
      # {Fw.Worker, arg},
      Fw.Backlight,
      Fw.StartClustering,
      Fw.KeylightController,
      {Pomodoro.PomodoroTimer, []},
      Fw.QuantumScheduler,
      Fw.MyProxy
    ]
  end
end
