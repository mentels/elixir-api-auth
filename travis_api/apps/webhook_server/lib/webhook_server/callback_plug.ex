defmodule WebhookServer.CallbackPlug do
  use Plug.Router

  require Logger
  alias WebhookServer.TravisClient

  plug(:signature_header_plug)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :json],
    body_reader: {WebhookServer.CacheBodyReader, :read_body, []},
    pass: ["text/*"],
    json_decoder: Jason
  )

  plug(:signature_validation_plug)
  plug(:match)
  plug(:dispatch)

  post "/api/webhook" do
    Logger.info("POST /api/webhook Params: #{inspect(conn.params)}")
    Logger.info("POST /api/webhook body: #{inspect(conn.assigns[:raw_body])}")
    send_resp(conn, 200, "ok")
  end

  defp signature_header_plug(conn, _opts) do
    case Plug.Conn.get_req_header(conn, "signature") do
      [] ->
        Logger.error("Missing Signature, sending 400 and halting the connection")
        conn = send_resp(conn, 400, "")
        halt(conn)
      [signature] ->
        assign(conn, :signature, signature)
    end
  end

  defp signature_validation_plug(conn, _opts) do
    [signature] = Plug.Conn.get_req_header(conn, "signature")
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
    :public_key.verify(body, :sha, Base.decode64!(signature), public_key())
  end

  defp public_key() do
    pkey_bin = public_key_bin(pk_method())
    [enc_pkey] = :public_key.pem_decode(pkey_bin)
    :public_key.pem_entry_decode(enc_pkey)
  end

  defp public_key_bin(:local) do
    :code.priv_dir(:travis_server)
    |> to_string
    |> Kernel.<>("/public.pem")
    |> File.read!()
  end
  defp public_key_bin(:travis) do
    {:ok, pkey_bin} = TravisClient.public_key_bin()
    pkey_bin
  end

  defp pk_method(),
    do: Env.fetch!(:webhook_server, :pk_method) |> String.to_existing_atom()

end
