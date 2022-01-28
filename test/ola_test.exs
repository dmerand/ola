defmodule OlaTest do
  use ExUnit.Case
  doctest Ola

  alias Ola
  alias Ola.Dictionary

  test "increment + lookup value" do
    Ola.parse("testword")
    assert %{"e" => e, "w" => w} = Dictionary.lookup("t")
    assert e > 0
    assert w > 0
  end

  test "ignores spaces" do
    Ola.parse("    spaces")
    assert %{} == Dictionary.lookup(" ")
  end

  test "parsing a full dictionary" do
    Ola.parse_dictionary("assets/words")
    assert %{"a" => a} = Dictionary.lookup("z")
    assert %{"i" => i} = Dictionary.lookup("w")
    assert a >= 14
    assert i > 100
  end
end
