defmodule Ola.DictionaryTest do
  use ExUnit.Case

  alias Ola.Dictionary

  setup do
    Dictionary.flush()
  end

  test "increment + lookup value" do
    Dictionary.increment("a", "a")
    assert %{"a" => 1} = Dictionary.lookup("a")

    Dictionary.increment("a", "a")
    Dictionary.increment("a", "b", 5)

    assert %{"a" => 2, "b" => 5} = Dictionary.lookup("a")
  end

  test "weird keys/values" do
    Dictionary.increment("💩", "a")
    assert %{"a" => 1} = Dictionary.lookup("💩")

    Dictionary.increment("a", "💩")
    assert %{"💩" => 1} = Dictionary.lookup("a")
  end

  test "n-grams of arbitrary length" do
    Dictionary.increment("donald", "merand")
    assert %{"merand" => 1} = Dictionary.lookup("donald")
  end

  test "map() and keys()" do
    Dictionary.increment("cool", "beans")
    Dictionary.increment("a", "b")

    assert %{"cool" => %{"beans" => 1}} = Dictionary.map()
    assert %{1 => _, 4 => _} = Dictionary.keys()
  end

  test "random key" do
    Dictionary.increment("a", "a")
    assert "a" == Dictionary.random_key()

    Dictionary.increment("aaa", "a")
    three = Dictionary.random_key(3)
    assert "aaa" == three

    diminishing_two = Dictionary.random_key(2)
    assert "a" == diminishing_two
  end

  test "probable next key" do
    Ola.train("donoldo")
    counts = Enum.reduce(0..100, %{"l" => 0, "n" => 0}, fn _i, tally ->
      key = Dictionary.probable_next_key("o")
      increment = Map.get(tally, key) + 1
      Map.put(tally, key, increment)
    end)

    assert Map.get(counts, "l") > 20 
    assert Map.get(counts, "n") > 20
  end
end
