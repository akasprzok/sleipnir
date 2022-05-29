defmodule SleipnirTest do
  use ExUnit.Case
  doctest Sleipnir

  test "greets the world" do
    assert Sleipnir.hello() == :world
  end
end
