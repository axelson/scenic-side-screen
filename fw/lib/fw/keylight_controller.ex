defmodule Fw.KeylightController do
  use GenServer
  require Logger

  defmodule State do
    defstruct [:devices]
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

    initial_state = %State{devices: devices}
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
    devices = Keylight.discover()
    Logger.info("keylight devices: #{inspect(devices, pretty: true)}")

    initial_state = %State{devices: devices}
    {:reply, :ok, initial_state}
  end

  def handle_call(:get_devices, _from, %State{} = state) do
    {:reply, state.devices, state}
  end
end
