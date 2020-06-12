defmodule Fw.Backlight do
  use GenServer
  require Logger

  @default_brightness 255

  # Partially inspired by
  # https://github.com/jjcarstens/hub/blob/c3f5bb947dd79fa26aa2c654a498da75ea2c4713/atm/lib/atm/session.ex#L134
  @brightness_file "/sys/class/backlight/rpi_backlight/brightness"
  @sys_backlight "/sys/class/backlight/rpi_backlight/bl_power"

  # Public API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def brightness(value) when value >= 0 and value <= 255 do
    # Enum.each(Node.list(), fn node ->
    #   Logger.debug("Sending external brightness to: #{node}")
    #   :rpc.call(node, PhxKiosk.Backlight, :external_brightness, [value])
    # end)

    do_brightness(value)
  end

  def brightness(_value) do
    {:error, "Value must be >= 0 and <= 255"}
  end

  def brightness() do
    GenServer.call(__MODULE__, :brightness)
  end

  def external_brightness(value) when value >= 0 and value <= 255 do
    IO.puts("external broadcast...")
    IO.inspect(value, label: "value")
    Logger.debug("Received external brightness #{value} on #{Node.self()}")

    # Uncomment this line to demonstrate the channel recovering
    # PhxKioskWeb.Endpoint.broadcast("home:lobby", "brightness", %{value: value})

    # PhxKioskWeb.Endpoint.broadcast("home:lobby", "brightness", %{"value" => value})

    do_brightness(value)
  end

  def do_brightness(value) when value >= 0 and value <= 255 do
    Logger.debug("in do_brightness with #{value}")
    GenServer.call(__MODULE__, {:brightness, value})
  end

  # def external_drawline(params) do
  #   PhxKioskWeb.Endpoint.broadcast("home:lobby", "drawLine", params)
  # end

  # GenServer Callbacks

  def init(_) do
    IO.puts("backlight init!")
    Logger.info("backlight init!")
    {:ok, @default_brightness}
  end

  def handle_call(:brightness, _from, brightness) do
    {:reply, brightness, brightness}
  end

  def handle_call({:brightness, value}, _from, _brightness) do
    Logger.debug("in handle_call brightness with #{value}")
    set_screen_brightness(value)

    {:reply, value, value}
  end

  defp nerves?, do: File.exists?(@brightness_file)

  defp set_screen_brightness(value) do
    if nerves?() do
      value = value |> round() |> to_string()
      # TODO: FINISH this
      # File.write(@sys_backlight, "1")
      File.write(@brightness_file, value)
    else
      # mac_brightness = (value / 255) |> to_string()
      # System.cmd("brightness", [mac_brightness])
    end
  end
end
