defmodule DerivcotestTest do
  use ExUnit.Case
  doctest Derivcotest

  test "greets the world" do
    assert Derivcotest.hello() == :world
  end
end
