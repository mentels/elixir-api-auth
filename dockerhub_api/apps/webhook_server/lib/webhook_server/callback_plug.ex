defmodule WebhookServer.CallbackPlug do
  use Plug.Router

  require Logger
  alias WebhookServer.DockerhubClient, as: Client

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["text/*"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  post "/api/webhook" do
    Logger.info("POST /api/webhook Params: #{inspect(conn.params)}")
    send_resp(conn, 200, "ok")
    validate_callback_uri = validate_callback_uri(conn.params["callback_url"])
    case Client.validate_webhook_callback(validate_callback_uri) do
      {:ok, _} ->
        Logger.debug("Successfully validated webhook")

      {:error, code} ->
        Logger.error("Failed to validate webhook via " <>
          "callback_url=#{conn.params["callback_url"]} return_code=#{code}")
    end
  end

  defp validate_callback_uri(url) do
    URI.parse(url)
  end

end
