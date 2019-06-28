defmodule WebhookServer.DockerhubClient do
  @moduledoc """
  Dockherhub client for validating webhook callbacks

  See: https://docs.docker.com/docker-hub/webhooks/#validating-a-webhook-callback
  """

  require Logger

  def validate_webhook_callback(uri, payload \\ default_payload) do
    {:ok, conn} = Mint.HTTP.connect(uri.scheme |> String.to_atom(), uri.host, uri.port)
    {:ok, conn, ref} = Mint.HTTP.request(conn, "POST", uri.path, [])

    {:ok, _conn, response} = response(conn)
    {:ok, _conn} = Mint.HTTP.close(conn)

    Enum.find_value(response, fn
      {:status, ^ref, 200} -> {:ok, 200}
      {:status, ^ref, code} -> {:error, code}
    end)
  end

  defp default_payload() do
    Jason.encode!(%{:state => :success})
  end

  defp response(conn) do
    Mint.HTTP.stream(
      conn,
      receive do
        msg ->
          msg
      end
    )
  end
end
