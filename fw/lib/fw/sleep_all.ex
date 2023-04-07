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
      # If my cursor is on the laptop, then when the laptop goes to sleep my
      # cursor comes back to the desktop causing the desktop to wake up. I solve
      # this by telling the desktop to sleep again
      Process.sleep(3_000)

      Fw.JaxSSH.connect(
        ip: "192.168.1.4",
        key_path: "/data/desktop_sleep_screen_ed25519",
        known_hosts_path: "/tmp/known_hosts",
        user: "jason"
      )
    end)

    Task.start(fn ->
      Fw.JaxSSH.connect(
        ip: "192.168.1.18",
        key_path: "/data/felt_laptop_sleep_screen_ed25519",
        known_hosts_path: "/tmp/known_hosts",
        user: "jason"
      )
    end)

    Task.start(fn ->
      GoveePhxApplication.BLESupervisor.get_conns()
      |> Enum.each(fn conn ->
        GoveePhxApplication.BLESupervisor.execute_command(Govee.Command.turn_off(), conn)
      end)
    end)

    Task.start(fn ->
      Fw.KeylightController.off()
    end)

    PianoUi.remote_cmd(:stop)
  end
end
