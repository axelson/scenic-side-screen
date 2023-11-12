defmodule Fw do
  def stop_for_the_night do
    Task.start(fn ->
      GoveePhx.all_off()
    end)

    Task.start(fn ->
      Fw.KeylightController.off()
    end)

    stop_music()
  end

  def stop_music do
    PianoUi.remote_cmd(:stop)
  end
end
