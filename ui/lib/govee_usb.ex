defmodule GoveeUsb do
  @moduledoc """
  Sample ATT application that can control the Govee LED Light Bulb

  They can be found [here](https://www.amazon.com/MINGER-Dimmable-Changing-Equivalent-Multi-Color/dp/B07CL2RMR7/)
  """

  use GenServer
  require Logger

  alias BlueHeron.HCI.Command.{
    ControllerAndBaseband.WriteLocalName,
    LEController.SetScanEnable
  }

  alias BlueHeron.HCI.Event.{
    LEMeta.ConnectionComplete,
    DisconnectionComplete,
    LEMeta.AdvertisingReport,
    LEMeta.AdvertisingReport.Device
  }

  # Sets the name of the BLE device
  @write_local_name %WriteLocalName{name: "Govee Controller"}

  @default_uart_config %{
    device: "ttyACM0",
    uart_opts: [speed: 115_200],
    init_commands: [@write_local_name]
  }

  @default_usb_config %{
    vid: 0x0A5C,
    pid: 0x21E8,
    init_commands: [@write_local_name]
  }

  @doc """
  Start a linked connection to the bulb

  ## UART

      iex> {:ok, pid} = GoveeBulb.start_link(:uart, device: "ttyACM0")
      {:ok, #PID<0.111.0>}

  ## USB

      iex> {:ok, pid} = GoveeBulb.start_link(:usb)
      {:ok, #PID<0.111.0>}
  """
  def start_link(transport_type, config \\ %{})

  def start_link(:uart, config) do
    config = struct(BlueHeronTransportUART, Map.merge(@default_uart_config, config))
    GenServer.start_link(__MODULE__, config, [])
  end

  def start_link(:usb, config) do
    config = struct(BlueHeronTransportUSB, Map.merge(@default_usb_config, config))
    GenServer.start_link(__MODULE__, config, [])
  end

  @doc """
  Set the color of the bulb.

      iex> GoveeBulb.set_color(pid, 0xFFFFFF) # full white
      :ok
      iex> GoveeBulb.set_color(pid, 0xFF0000) # full red
      :ok
      iex> GoveeBulb.set_color(pid, 0x00FF00) # full green
      :ok
      iex> GoveeBulb.set_color(pid, 0x0000FF) # full blue
      :ok
  """
  def set_color(pid, rgb) do
    GenServer.call(pid, {:set_color, rgb})
  end

  def turn_off(pid) do
    GenServer.call(pid, :turn_off)
  end

  def turn_on(pid) do
    GenServer.call(pid, :turn_on)
  end

  def set_brightness(pid, brightness) do
    GenServer.call(pid, {:set_brightness, brightness})
  end

  def set_white(pid, value) do
    GenServer.call(pid, {:set_white, value})
  end

  @impl GenServer
  def init(config) do
    # Create a context for BlueHeron to operate with
    {:ok, ctx} = BlueHeron.transport(config)

    # Subscribe to HCI and ACL events
    BlueHeron.add_event_handler(ctx)

    # Start the ATT Client (this is what we use to read/write data with)
    {:ok, conn} = BlueHeron.ATT.Client.start_link(ctx)

    {:ok, %{conn: conn, ctx: ctx, connected?: false}}
  end

  @impl GenServer

  # Sent when a transport connection is established
  def handle_info({:BLUETOOTH_EVENT_STATE, :HCI_STATE_WORKING}, state) do
    # Enable BLE Scanning. This will deliver messages to the process mailbox
    # when other devices broadcast
    BlueHeron.hci_command(state.ctx, %SetScanEnable{le_scan_enable: true})
    {:noreply, state}
  end

  # Match for the Bulb.
  def handle_info(
        {:HCI_EVENT_PACKET,
         %AdvertisingReport{devices: [%Device{address: addr, data: ["\tMinger" <> _]}]}},
        state
      ) do
    Logger.info("Trying to connect to Govee LED #{inspect(addr, base: :hex)}")
    # Attempt to create a connection with it.
    :ok = BlueHeron.ATT.Client.create_connection(state.conn, peer_address: addr)
    {:noreply, state}
  end

  # ignore other HCI Events
  def handle_info({:HCI_EVENT_PACKET, _}, state), do: {:noreply, state}

  # ignore other HCI ACL data (ATT handles this for us)
  def handle_info({:HCI_ACL_DATA_PACKET, _}, state), do: {:noreply, state}

  # Sent when create_connection/2 is complete
  def handle_info({BlueHeron.ATT.Client, conn, %ConnectionComplete{}}, %{conn: conn} = state) do
    Logger.info("Govee LED connection established")
    {:noreply, %{state | connected?: true}}
  end

  # Sent if a connection is dropped
  def handle_info({BlueHeron.ATT.Client, _, %DisconnectionComplete{reason_name: reason}}, state) do
    Logger.warn("Govee LED connection dropped: #{reason}")
    {:noreply, %{state | connected?: false}}
  end

  # Ignore other ATT data
  def handle_info({BlueHeron.ATT.Client, _, _event}, state) do
    {:noreply, state}
  end

  @command_power 0x01
  @command_brightness 0x04
  @command_color 0x05

  @led_mode_manual 0x02
  # @led_mode_microphone 0x06
  # @led_mode_scenes 0x05

  @impl GenServer
  # Assembles the raw RGB data into a binary that the bulb expects
  # this was found here https://github.com/Freemanium/govee_btled#analyzing-the-traffic
  def handle_call({:set_color, _rgb}, _from, %{connected?: false} = state) do
    Logger.warn("Not currently connected to a bulb")
    {:reply, {:error, :disconnected}, state}
  end

  def handle_call({:set_color, rgb}, _from, state) do
    build_command(@command_color, <<@led_mode_manual, rgb::24, 0, rgb::24>>)
    |> send_command(state.conn)
    |> case do
      :ok ->
        Logger.info("Setting Govee LED Color: ##{inspect(rgb, base: :hex)}")
        {:reply, :ok, state}

      error ->
        Logger.info("Failed to set Govee LED color")
        {:reply, error, state}
    end
  end

  def handle_call(:turn_off, _from, %{connected?: false} = state) do
    Logger.warn("Not connected to a bulb")
    {:reply, {:error, :disconnected}, state}
  end

  def handle_call(:turn_off, _from, state) do
    build_command(@command_power, <<0>>)
    |> send_command(state.conn)
    |> case do
      :ok ->
        Logger.info("Turned Govee off")
        {:reply, :ok, state}

      error ->
        Logger.info("Failed to turn Govee off #{inspect(error)}")
        {:reply, error, state}
    end
  end

  def handle_call(:turn_on, _from, %{connected?: false} = state) do
    Logger.warn("Not connected to a bulb")
    {:reply, {:error, :disconnected}, state}
  end

  def handle_call(:turn_on, _from, state) do
    Logger.info("try to turn on")

    build_command(@command_power, <<0x1>>)
    |> send_command(state.conn)
    |> case do
      :ok ->
        Logger.info("Turned Govee on")
        {:reply, :ok, state}

      error ->
        Logger.info("Failed to turn Govee on #{inspect(error)}")
        {:reply, error, state}
    end
  end

  def handle_call({:set_brightness, brightness}, _from, state) do
    build_command(@command_brightness, <<brightness>>)
    |> send_command(state.conn)
    |> case do
      :ok ->
        Logger.info("Set brightness")
        {:reply, :ok, state}

      error ->
        Logger.info("Failed to set brightness #{inspect(error)}")
        {:reply, error, state}
    end
  end

  def handle_call({:set_white, value}, _from, state) do
    build_command(@command_color, <<@led_mode_manual, 0xFF, 0xFF, 0xFF, 0x1, value::24>>)
    |> send_command(state.conn)
    |> case do
      :ok ->
        Logger.info("Set white")
        {:reply, :ok, state}

      error ->
        Logger.warn("Failed to set white #{inspect(error)}")
        {:reply, error, state}
    end
  end

  defp send_command(command, conn) do
    handle = 0x0015
    BlueHeron.ATT.Client.write(conn, handle, command)
  end

  defp build_command(command, payload) do
    value = pad(<<0x33, command, payload::binary>>)
    checksum = calculate_xor(value, 0)
    <<value::binary-19, checksum::8>>
  end

  def pad(binary) when byte_size(binary) == 19, do: binary

  def pad(binary) do
    pad(<<binary::binary, 0>>)
  end

  defp calculate_xor(<<>>, checksum), do: checksum

  defp calculate_xor(<<x::8, rest::binary>>, checksum),
    do: calculate_xor(rest, :erlang.bxor(checksum, x))
end
