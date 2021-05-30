defmodule Fw.StartClustering do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl GenServer
  def init(_opts) do
    :ok = VintageNet.subscribe(["interface", "eth0"])
    {:ok, nil, {:continue, :start_epmd}}
  end

  @impl GenServer
  def handle_continue(:start_epmd, state) do
    {"", 0} = System.cmd("epmd", ["-daemon"])
    _ = Node.start(:"murphy@192.168.1.6")

    {:noreply, state}
  end

  @impl GenServer
  def handle_info({VintageNet, ["interface", "eth0", "connection"], _, :internet, _metadata}, state) do
    connect_remote_nodes()
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.debug("Ignoring VintageNet event: #{inspect(msg)}")
    {:noreply, state}
  end

  defp connect_remote_nodes do
    Application.fetch_env!(:fw, :nodes)
    |> Enum.each(fn node ->
      Logger.info("Trying to connect to #{node}")
      case Node.connect(node) do
        true -> Logger.info("Connected to #{node}")
        false -> Logger.info("Unable to connect to #{node}")
      end
    end)
  end
end
