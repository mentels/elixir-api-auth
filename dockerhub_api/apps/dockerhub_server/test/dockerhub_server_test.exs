defmodule DockerhubServerTest do
  use ExUnit.Case
  doctest DockerhubServer

  test "greets the world" do
    assert DockerhubServer.hello() == :world
  end
end
