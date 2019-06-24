defmodule GithubServer do
  @moduledoc """
  Simulates Github Webhooks

  It simply calls the given URL with the X-Hub-Signature as described at:
  https://developer.github.com/webhooks/securing/
  """

  def call(uri \\ default_uri(), headers \\ [], payload \\ default_payload()) do
    # headers = [signature(secret(), payload) | headers]
    headers = [content_type(), signature(secret(), payload) | headers]
    {:ok, conn} = Mint.HTTP.connect(uri.scheme |> String.to_atom(), uri.host, uri.port)
    {:ok, conn, ref} =
      Mint.HTTP.request(conn, "POST", uri.path, headers, payload)

    {:ok, _conn, response} = response(conn)
    {:ok, _conn} = Mint.HTTP.close(conn)

    Enum.find_value(response, fn
      {:status, ^ref, 200} -> {:ok, 200, fetch_body(ref, response)}
      {:status, ^ref, code} -> {:error, code, fetch_body(ref, response)}
    end)
  end

  defp default_uri() do
    URI.parse("http://localhost:4000/api/webhook")
  end

  defp default_payload() do
    Jason.encode!(%{"key" => "val"})
  end

  defp content_type() do
    {"content-type", "application/json"}
  end

  defp signature(secret, payload) do
    sig = "sha1=" <> :crypto.hmac(:sha, secret, payload) |> Base.encode16(case: :lower)
    {"X-Hub-Signature", sig}
  end

  defp secret(), do: Env.fetch!(:github_server, :secret)

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
      {:data, ^ref, body} -> body
      _ -> false
    end)
  end
end
