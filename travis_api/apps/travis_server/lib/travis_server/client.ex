defmodule TravisServer.Client do
  @moduledoc """
  Simulates Travis Webhooks

  It simply calls the given URL with the Signature header as described at:
  https://docs.travis-ci.com/user/notifications/
  """

  def call(uri \\ default_uri(), headers \\ [], payload \\ default_payload()) do
    headers = [content_type(), signature(payload) | headers]
    {:ok, conn} = Mint.HTTP.connect(uri.scheme |> String.to_atom(), uri.host, uri.port)
    {:ok, conn, ref} = Mint.HTTP.request(conn, "POST", uri.path, headers, payload)

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

  defp signature(payload) do
    sig = :public_key.sign(payload, :sha, private_key()) |> Base.encode64(case: :lower)
    {"Signature", sig}
  end

  defp private_key() do
    skey_bin = File.read!(priv_key_path())
    [enc_skey] = :public_key.pem_decode(skey_bin)
    :public_key.pem_entry_decode(enc_skey)
  end

  defp priv_key_path() do
    (:code.priv_dir(:travis_server) |> to_string) <> "/private.pem"
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
      {:data, ^ref, body} -> body
      _ -> false
    end)
  end
end
