defmodule TravisServerTest do
  use ExUnit.Case
  doctest TravisServer

  test "greets the world" do
    assert TravisServer.hello() == :world
  end
end
