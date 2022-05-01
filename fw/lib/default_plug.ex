defmodule Fw.DefaultPlug do
  import Phoenix.LiveView.Helpers

  def init(opts), do: opts

  def call(conn, _opts) do
    assigns = %{
      domains:
        [
          Application.fetch_env!(:fw, :govee_phx_domain),
          Application.fetch_env!(:fw, :asteroids_domain),
          Application.fetch_env!(:fw, :livebook_domain)
        ]
        |> Enum.map(&"http://#{&1}")
    }

    html = ~H"""
    <html>
      <body>
        <h2>Nerves Side Screen</h2>
        <ul>
          <%= for domain <- @domains do %>
            <li><a href={domain}><%= domain %></a></li>
          <% end %>
        </ul>
      </body>
    </html>
    """

    iodata = Phoenix.HTML.Safe.to_iodata(html)
    html = List.to_string(iodata)

    Plug.Conn.send_resp(conn, 200, html)
  end
end
