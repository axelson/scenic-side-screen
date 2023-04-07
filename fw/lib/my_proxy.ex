defmodule Fw.MyProxy do
  use MainProxy.Proxy

  def backends do
    [
      %{
        domain: Application.fetch_env!(:fw, :govee_phx_domain),
        phoenix_endpoint: GoveePhxWeb.Endpoint
      },
      %{
        domain: Application.fetch_env!(:fw, :asteroids_domain),
        phoenix_endpoint: PlayWeb.Endpoint
      },
      %{
        domain: Application.fetch_env!(:fw, :pomodoro_phx_domain),
        phoenix_endpoint: PomodoroPhxWeb.Endpoint
      },
      %{
        domain: Application.fetch_env!(:fw, :livebook_domain),
        phoenix_endpoint: LivebookWeb.Endpoint
      },
      %{
        plug: Fw.DefaultPlug
      },
    ]
  end

  # # Optional callback
  # @impl MasterProxy
  # def merge_config(:https, opts) do
  #   Config.Reader.merge(opts, SiteEncrypt.https_keys(ProxyWeb.Endpoint))
  # end

  # def merge_config(:http, opts), do: opts
end
