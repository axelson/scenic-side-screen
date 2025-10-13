defmodule Fw.PomodoroObsidianLogger do
  use GenServer
  require Logger
  alias Pomodoro.PomodoroTimer

  defmodule State do
    defstruct status: :unknown
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(_) do
    PomodoroTimer.register()
    %PomodoroTimer{status: status} = PomodoroTimer.get_timer()
    initial_state = %State{status: status}
    {:ok, initial_state}
  end

  @impl GenServer
  def handle_info({:pomodoro_timer, %PomodoroTimer{} = pomodoro_timer}, %State{} = state) do
    current_status = state.status
    new_status = pomodoro_timer.status

    case {current_status, new_status} do
      {:unknown, :running} -> send_to_obsidian("Pomodoro started")
      {:initial, :running} -> send_to_obsidian("Pomodoro started")
      {:running, :resting} -> send_to_obsidian("Pomodoro resting")
      {:limbo, :resting} -> send_to_obsidian("Pomodoro resting")
      {:limbo_finished, :resting} -> send_to_obsidian("Pomodoro resting")
      _ -> :ok
    end

    state = %State{state | status: new_status}
    {:noreply, state}
  end

  def handle_info({task_ref, _state}, state) when is_reference(task_ref) do
    {:noreply, state}
  end

  def handle_info({:DOWN, _task_ref, :process, _pid, _reason}, state) do
    {:noreply, state}
  end

  def send_to_obsidian(message) do
    date_str =
      DateTime.now!("Etc/UTC")
      |> DateTime.shift_zone!("Pacific/Honolulu")
      |> Calendar.strftime("%H:%M")

    Task.Supervisor.async_nolink(:fw_task_supervisor, fn ->
      Fw.JaxSSH.run_command("add_pomodoro_log #{date_str} #{message}",
        ip: "192.168.1.18",
        key_path: "/data/felt_laptop_run_command_ed25519",
        known_hosts_path: "/tmp/known_hosts",
        user: "jason"
      )
    end)
  end
end
