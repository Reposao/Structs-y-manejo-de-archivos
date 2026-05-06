defmodule InventarioTest do
  use ExUnit.Case
  doctest Inventario

  test "greets the world" do
    assert Inventario.hello() == :world
  end
end
