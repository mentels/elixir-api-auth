defmodule WebhookServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: WebhookServer.CallbackPlug, options: [port: 4000]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
