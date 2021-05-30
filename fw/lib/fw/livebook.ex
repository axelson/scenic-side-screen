defmodule Fw.Livebook do
  def initialize_data_directory() do
    destination_dir = "/data/livebooks"
    source_dir = Application.app_dir(:fw, "priv")

    # Best effort create everything
    _ = File.mkdir_p(destination_dir)
    Enum.each(["welcome.livemd", "samples"], &symlink(source_dir, destination_dir, &1))
  end

  defp symlink(source_dir, destination_dir, filename) do
    source = Path.join(source_dir, filename)
    dest = Path.join(destination_dir, filename)

    _ = File.rm(dest)
    _ = File.ln_s(source, dest)
  end
end
