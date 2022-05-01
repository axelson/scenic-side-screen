defmodule Fw.ScreenCapture do
  @moduledoc """
  Simple utility to capture the screen contents via RpiFbCapture

  To view the screen capture you probably want to:

  ```sh
  # Copy the file (assuming you passed the path `"/data/capture.ppm"`) to your computer
  scp nerves-side-screen.local:/data/capture.ppm .

  # Use ImageMagick to convert the `.ppm` to `.jpg` for easier viewing and manipulation
  convert capture.ppm capture.jpg
  ```
  """

  def capture(path) do
    {:ok, pid} = RpiFbCapture.start_link(width: 0, height: 0)
    capture(pid, path)
  end

  def capture(pid, path) do
    {:ok, frame} = RpiFbCapture.capture(pid, :ppm)
    File.write(path, frame.data)
  end
end
