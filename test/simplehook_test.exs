defmodule SimplehookTest do
  use ExUnit.Case
  doctest Simplehook

  test "greets the world" do
    assert Simplehook.hello() == :world
  end
end
