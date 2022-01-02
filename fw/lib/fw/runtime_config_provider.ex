defmodule Fw.RuntimeConfigProvider do
  @moduledoc """
  Load a configuration file at runtime

  To use, add this line to your `release/0` in your `mix.exs` file:

      config_providers: [{Fw.RuntimeConfigProvider, "/data/.target.secret.exs"}]

  Example .target.secret.exs file:

      import Config

      config :my_app, MyAppWeb.Endpoint,
        secret_key_base: "f3oOjxCAcecru17e08gpPflY5fBVM6CIlErkJmHGId97dm2RjRImhURa7dc5i+21",
        live_view: [signing_salt: "7u3jXALN3l3krX/Nd6XNeC27gxwAxZV2"]
  """
  # NOTE: Logger messages are not used here because they are not being reported by RingLogger

  @behaviour Config.Provider

  def init(path) when is_binary(path), do: path

  def load(config, path) do
    if File.exists?(path) do
      Config.Reader.load(config, {path, []})
    else
      IO.warn("WARNING: Unable to load runtime config at #{inspect(path)}")
      config
    end
  rescue
    err ->
      IO.warn("WARNING: Unable to load runtime config due to error: #{inspect(err)}")
      config
  end
end
