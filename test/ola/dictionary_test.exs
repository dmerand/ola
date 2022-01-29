defmodule Ola.DictionaryTest do
  use ExUnit.Case

  alias Ola.Dictionary

  test "increment + lookup value" do
    Dictionary.increment("a", "a")
    assert %{"a" => a} = Dictionary.lookup("a")
    assert a >= 1

    Dictionary.increment("a", "a")
    Dictionary.increment("a", "b", 5)

    assert %{"a" => a, "b" => b} = Dictionary.lookup("a")
    assert a >= 2
    assert b >= 5
  end

  test "weird keys/values" do
    Dictionary.increment("💩", "a")
    assert %{"a" => a} = Dictionary.lookup("💩")
    assert a >= 1

    Dictionary.increment("a", "💩")
    assert %{"💩" => b} = Dictionary.lookup("a")
    assert b >= 1
  end

  test "n-grams of arbitrary length" do
    Dictionary.increment("donald", "merand")
    assert %{"merand" => a} = Dictionary.lookup("donald")
    assert a >= 1
  end

  test "all() returns a map" do
    Dictionary.increment("cool", "beans")
    assert %{"cool" => %{"beans" => a}} = Dictionary.all()
    assert a >= 1
  end

  test "random key" do
    Dictionary.increment("a", "a")
    assert Dictionary.random_key()

    Dictionary.increment("aaa", "a")
    assert Dictionary.random_key(3)
  end
end
