defmodule RedirectEndpointTest do
  use ExUnit.Case
  doctest RedirectEndpoint

  test "greets the world" do
    assert RedirectEndpoint.hello() == :world
  end
end
