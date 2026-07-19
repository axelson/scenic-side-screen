# Default instructions

To run the Nerves app:
  * `export MIX_TARGET=my_target` or prefix every command with
    `MIX_TARGET=my_target`. For example, `MIX_TARGET=rpi3`
  * Install dependencies with `mix deps.get`
  * Create firmware with `mix firmware`
  * Update secret configuration (on a subsequent deploy)
    * Run `cp .target.secret.example.exs .target.secret.exs`
    * Set all "<SNIP>" values in `.target.secret.exs`
    * Copy the secret configuration to the device with
      `scp .target.secret.exs nerves-side-screen.local:/data/.target.secret.exs`
  * Deploy/install
    * If it's the first time then run `mix firmware.burn`
    * If you are already running the code then `mix upload nerves-side-screen.local`
      Note: This requires an ssh key (see
      [nerves_ssh](https://github.com/nerves-project/nerves_ssh)
      for details)

You can use the Ramoops logger with `ssh nerves-side-screen.local`, then run `Ramoops.dump()`, this will show you the logs from the previous run.

# Running migration

``` sh
ssh nerves-side-screen.local
iex> PianoUi.Release.migrate()
iex> Pomodoro.Release.migrate()
```

# Accessing the web applications

- http://govee.nerves-side-screen.local
- http://asteroids.nerves-side-screen.local

# Installing suspend scripts

``` sh
cp contrib/arch_linux_desktop_suspend.sh /home/jason/bin/turn_off_screen.sh
```

Add a line like this to your `~/.ssh/authorized_keys` for the ssh key:
`command="/home/jason/turn_off_screen.sh" ssh-ed25519 AAAAC3N<snip>UnkHUj jason@jdesktop`

Alternatively you could run it with sudo by adding a line like this with `visudo`:
`jason ALL=(root) NOPASSWD: /root/suspend.sh`

## How this works
This uses the `Fw.JaxSSH` module to SSH in to the computer and run the given script

# Troubleshooting

If scenic doesn't launch then you may be affected by the bug https://github.com/boydm/scenic_new/issues/36 to fix it run the following:
```
rm -rf _build
dotenv mix firmware
mix firmware.burn
```

To fix the following error:
> (File.CopyError) could not copy recursively from "/home/jason/dev/scenic-side-screen/fw/_build/rpi3_dev/lib/play/priv" to "/home/jason/dev/scenic-side-screen/fw/_build/rpi3_dev/rel/fw/lib/play-0.1.0/priv". /home/jason/dev/scenic-side-screen/fw/_build/rpi3_dev/lib/play/static: no such file or directory

Run: `mkdir _build/rpi3_dev/lib/play/static`

# Pianobar

Pianobar is managed by `Fw.PianobarDaemon`, which launches it as a supervised Port process. Commands are sent via stdin.

## Selecting a station on startup

When pianobar first starts, it waits at the station selection prompt. So to select a station in that mode type:

```elixir
Fw.PianobarDaemon.select_station("0")
```

Replace `"0"` with the desired station number.

## Switching stations during playback

Send `s` to open the station change prompt, then select the station:

```elixir
Fw.PianobarDaemon.send_command("s")
Process.sleep(500)
Fw.PianobarDaemon.select_station("3")
```

The sleep gives pianobar time to present the station list before sending the selection.

## Listing stations

```elixir
PianoCtl.list_stations()
# => [{0, "Station Name"}, {1, "Another Station"}, ...]
```

The station list is populated from pianobar's event_command output (e.g. on the `usergetstations` event). It will be empty until pianobar has reported its stations at least once.

## Playback controls

```elixir
Fw.PianobarDaemon.send_command("p")   # pause/unpause
Fw.PianobarDaemon.send_command("n")   # next track
Fw.PianobarDaemon.send_command("+")   # love track
Fw.PianobarDaemon.send_command("-")   # ban track
Fw.PianobarDaemon.send_command("q")   # quit pianobar
```

These can also be sent via `PianoCtl.cmd/1` for the commands it supports (`:play_pause`, `:next`, `:play`, `:stop`, `:quit`).


# Asteroids Nerves Application

To run the Nerves app:
  * `export MIX_TARGET=my_target` or prefix every command with
    `MIX_TARGET=my_target`. For example, `MIX_TARGET=rpi3`
  * Install dependencies with `mix deps.get`
  * Create firmware with `mix firmware`
  * Burn to an SD card with `mix firmware.burn`

To update an already running project

Note: if scenic doesn't launch then you may be affected by the bug https://github.com/boydm/scenic_new/issues/36 to fix it run the following:
```
rm -rf _build
mix firmware
mix firmware.burn
```
