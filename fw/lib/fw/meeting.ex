defmodule Fw.Meeting do
  require Logger
  @behaviour PianoUi.MeetingBehaviour

  @impl PianoUi.MeetingBehaviour
  def start_meeting do
    Logger.info("Fw start meeting")
    Fw.KeylightController.on()

    Task.start(fn ->
      Fw.JaxSSH.run_command("SwitchToHyperXAudio",
        ip: "192.168.1.18",
        key_path: "/data/felt_laptop_run_command_ed25519",
        known_hosts_path: "/tmp/known_hosts",
        user: "jason"
      )
    end)

    # 2022-12-23 Disabling because it looks bad on my video
    # GoveeSemaphore.start_meeting()
  end

  @impl PianoUi.MeetingBehaviour
  def finish_meeting do
    Logger.info("Fw finish meeting")
    Fw.KeylightController.off()

    Task.start(fn ->
      Fw.JaxSSH.run_command("SwitchToDockAudio",
        ip: "192.168.1.18",
        key_path: "/data/felt_laptop_run_command_ed25519",
        known_hosts_path: "/tmp/known_hosts",
        user: "jason"
      )
    end)

    # 2022-12-23 Disabling because it looks bad on my video
    # GoveeSemaphore.finish_meeting()
  end
end

defmodule Fw.KeylightImpl do
  require Logger
  @behaviour PianoUi.KeylightBehaviour

  @impl PianoUi.KeylightBehaviour
  def on do
    Fw.KeylightController.on()
  end

  @impl PianoUi.KeylightBehaviour
  def off do
    Fw.KeylightController.off()
  end

  @impl PianoUi.KeylightBehaviour
  def reset do
    Fw.KeylightController.reset()
  end

  @impl PianoUi.KeylightBehaviour
  def set(opts) do
    Fw.KeylightController.set(opts)
  end

  @impl PianoUi.KeylightBehaviour
  def status do
    Fw.KeylightController.status()
    |> Map.values()
    |> case do
      [{_name, device_status}] ->
        %{"lights" => [%{"brightness" => brightness, "on" => on, "temperature" => temperature}]} =
          device_status

        result = %{brightness: brightness, temperature: temperature, on: on}
        {:ok, result}

      other ->
        Logger.info("#{__MODULE__} Received unexpected status: #{inspect(other, pretty: true)}")
        {:error, :unable_to_determine_status}
    end
  end
end
