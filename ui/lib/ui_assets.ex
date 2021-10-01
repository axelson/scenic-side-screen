defmodule Ui.Assets do
  use Scenic.Assets.Static,
    otp_app: :ui,
    sources: [
      "assets",
      {:piano_ui, PianoUi.Assets.asset_path()},
      {:play, Play.Assets.asset_path()},
      {:pomodoro, PomodoroUi.Assets.asset_path()},
      {:scenic, "deps/scenic/assets"}
    ],
    alias: [
      # roboto: {:scenic, "fonts/roboto.ttf"}
    ]
end
