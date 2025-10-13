defmodule Fw.MonitorControlImpl do
  @behaviour PianoUi.MonitorControlBehaviour

  @impl PianoUi.MonitorControlBehaviour
  def switch_to_desktop do
    Fw.JaxSSH.connect(
      ip: "192.168.1.4",
      key_path: "/data/desktop_monitor_switch_to_desktop_ed25519",
      known_hosts_path: "/tmp/known_hosts",
      user: "jason"
    )
  end

  @impl PianoUi.MonitorControlBehaviour
  def switch_to_dock do
    Fw.JaxSSH.connect(
      ip: "192.168.1.4",
      key_path: "/data/desktop_monitor_switch_to_dock_ed25519",
      known_hosts_path: "/tmp/known_hosts",
      user: "jason"
    )
  end

  @impl PianoUi.MonitorControlBehaviour
  def gaming_desktop_turn_on_monitor do
    Fw.JaxSSH.run_command("TurnOnMonitor",
      ip: "192.168.1.4",
      key_path: "/data/gaming_desktop_run_command_ed25519",
      known_hosts_path: "/tmp/known_hosts",
      user: "jason"
    )
  end

  @impl PianoUi.MonitorControlBehaviour
  def gaming_desktop_turn_off_monitor do
    Fw.JaxSSH.run_command("TurnOffMonitor",
      ip: "192.168.1.4",
      key_path: "/data/gaming_desktop_run_command_ed25519",
      known_hosts_path: "/tmp/known_hosts",
      user: "jason"
    )
  end
end
