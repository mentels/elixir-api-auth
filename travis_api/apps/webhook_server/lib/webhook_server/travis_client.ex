defmodule WebhookServer.TravisClient do
  @moduledoc """
  HTTP Client for fetch Travis config
  """

  require Logger

  def public_key_bin() do
    case get_travis_config() do
      {:ok, 200, body} ->
        Logger.debug("decoded_travis_body=#{inspect body}")
        {:ok, body[:config][:notifications][:webhook][:public_key]}

      {:error, code, _body} ->
        {:error, code}
    end
  end

  defp get_travis_config(uri \\ travis_uri()) do
    {:ok, conn} = Mint.HTTP.connect(uri.scheme |> String.to_atom(), uri.host, uri.port)
    {:ok, conn, ref} = Mint.HTTP.request(conn, "GET", uri.path, [])

    {:ok, _conn, response} = response(conn)
    {:ok, _conn} = Mint.HTTP.close(conn)

    Enum.find_value(response, fn
      {:status, ^ref, 200} -> {:ok, 200, fetch_body(ref, response)}
      {:status, ^ref, code} -> {:error, code, fetch_body(ref, response)}
    end)
  end

  defp travis_uri() do
    URI.parse("https://api.travis-ci.com/config")
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

  defp fetch_body(ref, response) do
    Enum.find_value(response, fn
      {:data, ^ref, body} ->
        Logger.debug("Fetched travis_config_body=#{inspect(body)}")
        Jason.decode!(body, keys: :atoms)

      _ ->
        false
    end)
  end
end
