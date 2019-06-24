defmodule WebhookServer.CallbackPlug do
  use Plug.Router

  require Logger

  plug(Plug.Parsers,
    parsers: [:urlencoded, :json],
    body_reader: {WebhookServer.CacheBodyReader, :read_body, []},
    pass: ["text/*"],
    json_decoder: Jason
  )

  plug(:body_hmac_plug)
  plug(:match)
  plug(:dispatch)

  post "/api/webhook" do
    Logger.info("POST /api/webhook Params: #{inspect(conn.params)}")
    Logger.info("POST /api/webhook body: #{inspect(conn.assigns[:raw_body])}")
    send_resp(conn, 200, "ok")
  end

  defp body_hmac_plug(conn, _opts) do
    [signature] = Plug.Conn.get_req_header(conn, "x-hub-signature")

    if not request_valid?(signature, conn.assigns[:raw_body]) do
      Logger.error("Invalid signature, sending OK 200 and halting connection")
      conn = send_resp(conn, 200, "ok")
      Plug.Conn.halt(conn)
    else
      Logger.debug("Signature valid")
      conn
    end
  end

  defp request_valid?(signature, body) do
    signature == signature(secret(), body)
  end

  defp signature(secret, payload) do
    ("sha1=" <> :crypto.hmac(:sha, secret, payload)) |> Base.encode16(case: :lower)
  end

  defp secret(), do: Env.fetch!(:webhook_server, :secret)
end
