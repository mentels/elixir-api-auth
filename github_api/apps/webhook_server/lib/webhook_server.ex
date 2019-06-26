defmodule WebhookServer do
  @moduledoc """
  Simulates server accepting Github Webhooks
  """

  @behaviour Application

  def start(_, _) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: WebhookServer.CallbackPlug, options: [port: 4000]}
    ]
    Supervisor.start_link(children, [strategy: :one_for_one])
  end

  def stop(_state) do
    :ok
  end
end
