defmodule UiApplication do
  def start(_type, _args) do
    main_viewport_config = Application.get_env(:play, :viewport)
    children = [
      {ScenicLiveReload, viewports: [main_viewport_config]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ui.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
