defmodule UiApplication do
  @moduledoc false

  def start(_type, _args) do
    main_viewport_config = Application.get_env(:ui, :viewport)
    children = [
      {Scenic, [main_viewport_config]},
      {ScenicLiveReload, viewports: [main_viewport_config]},
      {Pomodoro.PomodoroTimer, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ui.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
