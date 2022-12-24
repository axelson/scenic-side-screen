defmodule Fw.Meeting do
  require Logger
  @behaviour PianoUi.MeetingBehaviour

  @impl PianoUi.MeetingBehaviour
  def start_meeting do
    Logger.info("Fw start meeting")
    Fw.KeylightController.on()

    # 2022-12-23 Disabling because it looks bad on my video
    # GoveeSemaphore.start_meeting()
  end

  @impl PianoUi.MeetingBehaviour
  def finish_meeting do
    Logger.info("Fw finish meeting")
    Fw.KeylightController.off()

    # 2022-12-23 Disabling because it looks bad on my video
    # GoveeSemaphore.finish_meeting()
  end
end
