defmodule WebhookServer.CallbackPlug do
  use Plug.Router

  require Logger

  plug(:signature_header_plug)

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

  defp signature_header_plug(conn, _opts) do
    case Plug.Conn.get_req_header(conn, "x-hub-signature") do
      [] ->
        Logger.error("Missing x-hub-signature, sending 400 and halting the connection")
        conn = send_resp(conn, 400, "")
        halt(conn)
      [signature] ->
        assign(conn, :signature, signature)
    end
  end

  defp body_hmac_plug(conn, _opts) do
    [signature] = Plug.Conn.get_req_header(conn, "x-hub-signature")
    body = conn.assigns[:raw_body]
    Logger.debug("body=#{body}")

    if not request_valid?(signature, body) do
      Logger.error("Invalid signature, sending OK 200 and halting the connection")
      conn = send_resp(conn, 200, "ok")
      Plug.Conn.halt(conn)
    else
      Logger.debug("Signature valid")
      conn
    end
  end

  defp request_valid?(signature, body) do
    computed_signature = signature(secret(), body)
    Logger.debug("computed_signature=#{computed_signature}")
    signature == computed_signature
  end

  defp signature(secret, payload) do
    "sha1=" <> (:crypto.hmac(:sha, secret, payload) |> Base.encode16(case: :lower))
  end

  defp secret(), do: Env.fetch!(:webhook_server, :secret)
end
