defmodule AppyTest do
  use ExUnit.Case
  doctest Appy

  test "greets the world" do
    assert Appy.hello() == :world
  end
end
