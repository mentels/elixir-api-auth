defmodule TravisServer.Endpoint do
  use Plug.Router

  require Logger

  plug(:match)
  plug(:dispatch)

  get "/config" do
    Logger.info("GET /config")
    send_resp(conn, 200, response())
  end

  defp response() do
    %{config: %{notifications: %{webhook: %{public_key: public_key()}}}}
    |> Jason.encode!()
  end

  defp public_key() do
    :code.priv_dir(:travis_server)
    |> to_string
    |> Kernel.<>("/public.pem")
    |> File.read!()
  end
end
