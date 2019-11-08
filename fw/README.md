`dotenv mix firmware && ./upload.sh 192.168.1.6`

# Default instructions

To run the Nerves app:
  * `export MIX_TARGET=my_target` or prefix every command with
    `MIX_TARGET=my_target`. For example, `MIX_TARGET=rpi3`
  * Install dependencies with `mix deps.get`
  * Create firmware with `dotenv mix firmware`
  * Deploy/install
    * If it's the first time then run `mix firmware.burn`
    * If you are already running the code then `./upload.sh nerves.local`
      Note: This requires an ssh key (see
      [nerves_firmware_ssh](https://github.com/nerves-project/nerves_firmware_ssh)
      for details)

`dotenv` (from node or RubyGems) is required to set a value for `SLACK_TOKEN` which is used to connect to Slack

You can use the Ramoops logger with `ssh nerves.local`, then run `Ramoops.dump()`, this will show you the logs from the previous run.

# Troubleshooting

If scenic doesn't launch then you may be affected by the bug https://github.com/boydm/scenic_new/issues/36 to fix it run the following:
```
rm -rf _build
dotenv mix firmware
mix firmware.burn
```

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
