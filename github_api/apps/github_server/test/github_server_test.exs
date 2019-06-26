defmodule GithubServerTest do
  use ExUnit.Case
  doctest GithubServer

  test "greets the world" do
    assert GithubServer.hello() == :world
  end
end
