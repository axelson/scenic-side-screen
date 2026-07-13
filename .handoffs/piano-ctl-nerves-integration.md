# Handoff: piano_ctl Nerves Integration

## Goal

Run pianobar (CLI Pandora music player) and piano_ctl (its Elixir controller) directly on the Raspberry Pi touchscreen device, instead of on the desktop with Erlang clustering to the Pi.

## What's Done

### Pianobar on the Pi (fully working)
- Cross-compiled ARMv7 binary at `/root/pianobar/pianobar` with libs at `/root/pianobar/lib/`
- Config at `/root/.config/pianobar/config` (credentials, fifo path, event_command)
- Audio playback works via 3.5mm jack
- See `/Users/jason/dev/forks/pianobar/.handoffs/piano-ctl-nerves-integration.md` for cross-compilation details

### piano_ctl adapted for BusyBox/Nerves (uncommitted in piano_ctl repo)
Changes in `/Users/jason/dev/piano_ex/piano_ctl`:
- **`lib/templates/command.sh.eex`** — `#!/bin/sh`, `$(cat)` instead of bash-specific `$(</dev/stdin)`, removed PID check
- **`lib/piano_ctl/initializer.ex`** — Falls back to `mknod` when `mkfifo` unavailable; skips if FIFO exists
- **`lib/piano_ctl/command_runner.ex`** — BusyBox-compatible `ps | grep pianobar` instead of `ps -u $(id -u) -o comm`
- **`lib/notifier.ex`** — Embeds EEx template at compile time (`@template File.read!(@template_path)` + `EEx.eval_string`) so it works on the target where source files don't exist. Uses `PianoCtl.Config.event_command_path()` instead of hardcoded path.

### scenic-side-screen fw integration (partially committed)
- `fw/mix.exs` — Removed `runtime: false` from piano_ctl dep (committed in `2d6100e`)
- `fw/config/config.exs` — Added `config :piano_ctl, libcluster_hosts: []` (committed in `2d6100e`)
- `fw/lib/fw/pianobar_daemon.ex` — New GenServer wrapping pianobar via `Port.open` (staged, latest version unstaged)
- `fw/lib/fw/application.ex` — Added `Fw.PianobarDaemon` to supervision tree (staged)

### Key discoveries during debugging

1. **MuonTrap.Daemon cannot write to child stdin** — MuonTrap uses `\xFF` bytes as an internal acknowledgment protocol over the port. `Port.command` through MuonTrap injects these protocol bytes into the data stream, corrupting stdin. Solution: use `Port.open` directly.

2. **Pianobar has two input channels:**
   - **stdin** (via the Port) — for interactive prompts like station selection
   - **ctl FIFO** (`/root/.config/pianobar/ctl`) — for single-character playback commands (`p` pause, `n` next, etc.)
   - `PianoCtl.CommandRunner` sends commands via `echo "p" > /root/.config/pianobar/ctl` (shell, not `File.write!`)

3. **beam_notify works on Nerves** — Binary at `/srv/erlang/lib/beam_notify-1.0.0/priv/beam_notify`, tested end-to-end with BusyBox shell.

4. **BusyBox limitations verified on device:**
   - No `mkfifo` (use `mknod <path> p`)
   - No `/dev/stdin` (use `$(cat)`)
   - `ps` takes no arguments (no PID lookup)
   - `/bin/sh` is BusyBox, not bash

5. **`autostart_station = 0` doesn't work** — pianobar expects a station ID string, not an index. Currently pianobar boots to the station selection prompt and waits.

## Current State (deployed & running on Pi)

- Pianobar starts on boot, supervised by `Fw.PianobarDaemon`
- Sits at station selection prompt (no auto-play — user preference)
- Station selection: `Fw.PianobarDaemon.select_station("0")` from IEx
- Playback commands: `PianoCtl.cmd(:play_pause)` from IEx (goes through ctl FIFO)
- Both confirmed working on the device

## What's Next

### Untested: event pipeline (pianobar → piano_ctl)
The `command.sh` → `beam_notify` → `PianoCtl.PianoInputReader` → `PianoCtl.Server` pipeline has been adapted but **not tested end-to-end on the device**. This is what notifies piano_ctl of song changes (songstart, songfinish) so the UI can update. To test:
1. Start music: `Fw.PianobarDaemon.select_station("0")`
2. Check if `PianoCtl.Server.get_current_song()` returns song data
3. If not, check `/root/.config/pianobar/command.sh` contents and test manually

### Untested: pause/resume via PianoCtl.cmd
User had just started testing this when session ended. Verify:
```elixir
PianoCtl.cmd(:play_pause)  # should pause
PianoCtl.cmd(:play_pause)  # should resume
```

### Wire up the Piano UI
`PianoCtl.Visualizer` currently uses `Node.spawn/3` to call `PianoUi.Scene.Dashboard.update_song/1` on remote nodes. Since piano_ctl now runs on the same node as piano_ui, this could be simplified to a direct function call. But it may just work as-is since it iterates `Node.list()` which would include the local node... needs verification.

### Commit uncommitted work
- piano_ctl changes in `/Users/jason/dev/piano_ex/piano_ctl` are uncommitted
- `fw/lib/fw/pianobar_daemon.ex` latest version is unstaged (staged version is the MuonTrap.Daemon version, unstaged is the Port.open version)

### Consider: pianobar config management
The pianobar config file (`/root/.config/pianobar/config`) with credentials and `event_command` line is manually managed on the device. Could be generated or managed via rootfs_overlay or runtime config.

## Device Details

| Property | Value |
|----------|-------|
| Hostname | nerves-side-screen.local |
| IP | 192.168.1.6 |
| Hardware | Raspberry Pi 3 Model B Plus Rev 1.3 |
| SSH | Drops into IEx REPL (not shell) |
| Pianobar binary | `/root/pianobar/pianobar` |
| Pianobar libs | `/root/pianobar/lib/` |
| Pianobar config | `/root/.config/pianobar/config` |
| Writable storage | `/root/` (ext4) |
| beam_notify | `/srv/erlang/lib/beam_notify-1.0.0/priv/beam_notify` |

## Files to Review

| File | Repo | Status |
|------|------|--------|
| `fw/lib/fw/pianobar_daemon.ex` | scenic-side-screen | Unstaged (latest Port.open version) |
| `fw/lib/fw/application.ex` | scenic-side-screen | Staged |
| `fw/config/config.exs` | scenic-side-screen | Committed |
| `fw/mix.exs` | scenic-side-screen | Committed |
| `piano_ctl/lib/templates/command.sh.eex` | piano_ex | Uncommitted |
| `piano_ctl/lib/notifier.ex` | piano_ex | Uncommitted |
| `piano_ctl/lib/piano_ctl/initializer.ex` | piano_ex | Uncommitted |
| `piano_ctl/lib/piano_ctl/command_runner.ex` | piano_ex | Uncommitted |
