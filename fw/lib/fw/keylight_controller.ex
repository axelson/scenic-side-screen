defmodule Fw.KeylightController do
  use GenServer
  require Logger

  defmodule State do
    defstruct [:devices, :connected?]
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def on(name \\ __MODULE__) do
    GenServer.call(name, :on)
  end

  def off(name \\ __MODULE__) do
    GenServer.call(name, :off)
  end

  def reset(name \\ __MODULE__) do
    GenServer.call(name, :reset)
  end

  def get_devices(name \\ __MODULE__) do
    GenServer.call(name, :get_devices)
  end

  def set(name \\ __MODULE__, opts) do
    GenServer.call(name, {:set, opts})
  end

  def status(name \\ __MODULE__) do
    GenServer.call(name, :status)
  end

  @impl GenServer
  def init(opts) do
    {:ok, nil, {:continue, opts}}
  end

  @impl GenServer
  def handle_continue(opts, nil = _state) do
    # yes this is hacky
    start_delay = Keyword.get(opts, :start_delay, 5_000)
    Process.sleep(start_delay)

    devices = Keylight.discover()
    Logger.info("keylight devices: #{inspect(devices, pretty: true)}")

    connected? = check_connected(devices)
    broadcast_connected(connected?)
    initial_state = %State{devices: devices, connected?: connected?}

    schedule_poll(0)

    {:noreply, initial_state}
  end

  @impl GenServer
  def handle_call(:on, _from, %State{} = state) do
    Keylight.on(state.devices)
    {:reply, :ok, state}
  end

  def handle_call(:off, _from, %State{} = state) do
    Keylight.off(state.devices)
    {:reply, :ok, state}
  end

  def handle_call(:reset, _from, _state) do
    Logger.info("#{__MODULE__} resetting via re-discovery")
    devices = Keylight.discover()
    Logger.info("keylight devices: #{inspect(devices, pretty: true)}")

    connected? = check_connected(devices)
    broadcast_connected(connected?)
    initial_state = %State{devices: devices, connected?: connected?}
    {:reply, :ok, initial_state}
  end

  def handle_call(:get_devices, _from, %State{} = state) do
    {:reply, state.devices, state}
  end

  def handle_call({:set, opts}, _from, %State{} = state) do
    reply = Keylight.set(state.devices, opts)
    {:reply, reply, state}
  end

  def handle_call(:status, _from, %State{} = state) do
    reply = Keylight.status(state.devices)
    {:reply, reply, state}
  end

  @impl GenServer
  def handle_info(:poll, %State{} = state) do
    Logger.info("polling keylight status")
    connected? = check_connected(state.devices)
    Logger.info("new connected? is #{inspect(connected?)}")
    broadcast_connected(connected?)

    state = %State{state | connected?: connected?}
    schedule_poll()
    {:noreply, state}
  end

  defp check_connected(devices) do
    case Keylight.status(devices) do
      %{} = map ->
        Enum.any?(map, fn
          {_, {:ok, _}} -> true
          {_, {:error, _}} -> false
        end)
        |> tap(fn res ->
          Logger.info("check_connected res: #{inspect(res, pretty: true)}")
        end)

      other ->
        Logger.warn("assuming not connected based on status result: #{inspect(other)}")
        false
    end
  end

  defp schedule_poll(timeout \\ 15_000) do
    Process.send_after(self(), :poll, timeout)
  end

  defp broadcast_connected(connected?) do
    Phoenix.PubSub.broadcast(:piano_ui_pubsub, "keylight", {:connected?, connected?})
  end
end
