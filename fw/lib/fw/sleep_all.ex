defmodule Fw.SleepAll do
  def sleep_all do
    File.touch("/tmp/known_hosts")

    # TODO: Don't hard-code
    Task.start(fn ->
      Fw.JaxSSH.connect(
        ip: "192.168.1.4",
        key_path: "/data/desktop_sleep_screen_ed25519",
        known_hosts_path: "/tmp/known_hosts",
        user: "jason"
      )
    end)

    Task.start(fn ->
      Fw.JaxSSH.connect(
        ip: "192.168.1.7",
        key_path: "/data/felt_laptop_sleep_screen_ed25519",
        known_hosts_path: "/tmp/known_hosts",
        user: "jason"
      )
    end)

    PianoUi.remote_cmd(:stop)
  end
end
