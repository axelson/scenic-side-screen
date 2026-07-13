defmodule Fw.PianobarDaemon do
  use GenServer

  require Logger

  @pianobar_bin "/root/pianobar/pianobar"
  @pianobar_lib "/root/pianobar/lib"

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def select_station(station) do
    GenServer.cast(__MODULE__, {:write_stdin, "#{station}\n"})
  end

  def send_command(command) do
    GenServer.cast(__MODULE__, {:write_stdin, command})
  end

  @impl GenServer
  def init(_opts) do
    port =
      Port.open({:spawn_executable, @pianobar_bin}, [
        :binary,
        :exit_status,
        :stderr_to_stdout,
        {:env, [{~c"LD_LIBRARY_PATH", ~c"#{@pianobar_lib}"}]}
      ])

    Logger.info("Pianobar started")
    {:ok, %{port: port}}
  end

  @impl GenServer
  def handle_cast({:write_stdin, data}, state) do
    Port.command(state.port, data)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({port, {:data, data}}, %{port: port} = state) do
    data
    |> String.split("\n", trim: true)
    |> Enum.each(fn line ->
      line = String.replace(line, ~r/\e\[[0-9;]*[a-zA-Z]/, "")
      if line != "" do
        Logger.debug("pianobar: #{line}")
      end
    end)

    {:noreply, state}
  end

  def handle_info({port, {:exit_status, status}}, %{port: port} = state) do
    Logger.error("Pianobar exited with status #{status}")
    {:stop, {:pianobar_exit, status}, state}
  end
end
