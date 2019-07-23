defmodule UiTest do
  use ExUnit.Case
  doctest Ui

  test "greets the world" do
    assert Ui.hello() == :world
  end
end
