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

- http://livebook.nerves-side-screen.local
- http://govee.nerves-side-screen.local
- http://asteroids.nerves-side-screen.local

# Installing suspend scripts

``` sh
sudo cp contrib/arch_linux_desktop_suspend.sh /root/suspend.sh
```

Add a line like this to your `~/.ssh/authorized_keys` for the ssh key:
`command="sudo /root/suspend.sh" ssh-ed25519 AAAAC3N<snip>UnkHUj jason@jdesktop`

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
