defmodule Fw.JaxSSH do
  require Logger

  def config(opts \\ []) do
    key_path = Keyword.get(opts, :key_path)
    known_hosts_path = Keyword.get(opts, :known_hosts_path)
    passphrase = Keyword.get(opts, :passphrase, ~c"")
    user = Keyword.get(opts, :user)

    key = File.open!(key_path)
    known_hosts = File.open!(known_hosts_path, [:read, :write])

    # NOTE: with_options has a dialyzer error
    key_cb =
      SSHClientKeyAPI.with_options(
        identity: key,
        known_hosts: known_hosts,
        silently_accept_hosts: true,
        passphrase: passphrase
      )

    ssh_config = [
      user: to_charlist(user),
      auth_methods: ~c"publickey",
      user_interaction: false,
      silently_accept_hosts: true,
      key_cb: key_cb
    ]

    {key_cb, ssh_config}
  end

  def connect(opts \\ []) do
    ip = Keyword.get(opts, :ip)
    port = Keyword.get(opts, :port, 22)
    {_, ssh_config} = config(opts)

    {:ok, conn} = :ssh.connect(to_charlist(ip), port, ssh_config)
    {:ok, channel_id} = :ssh_connection.session_channel(conn, 5000)
    _shell = :ssh_connection.shell(conn, channel_id)
    # Sleep to let the command run on the external machine
    Process.sleep(5_000)
    :ssh_connection.close(conn, channel_id)
    :ssh.close(conn)
  end

  def run_command(command, opts \\ []) when is_binary(command) do
    ip = Keyword.get(opts, :ip)
    port = Keyword.get(opts, :port, 22)
    {_, ssh_config} = config(opts)

    {:ok, conn} = :ssh.connect(to_charlist(ip), port, ssh_config)
    {:ok, channel_id} = :ssh_connection.session_channel(conn, 5000)
    _shell = :ssh_connection.exec(conn, channel_id, to_charlist(command), 5000)
    # Sleep to let the command run on the external machine
    Process.sleep(5_000)
    :ssh_connection.close(conn, channel_id)
    :ssh.close(conn)
  end
end
