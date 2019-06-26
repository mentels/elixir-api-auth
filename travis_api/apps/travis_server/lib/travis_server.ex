defmodule TravisServer do
  @moduledoc """
  Simulates Travis Server

  Delivers webhooks and exposes endpoint with public key.
  """

  @behaviour Application

  def start(_, _) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: TravisServer.Endpoint, options: [port: 8000]}
    ]
    Supervisor.start_link(children, [strategy: :one_for_one])
  end

  def stop(_state) do
    :ok
  end

end
