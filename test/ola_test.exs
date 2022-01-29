defmodule OlaTest do
  use ExUnit.Case
  doctest Ola

  alias Ola.Dictionary

  @num_attempts 20

  setup do
    Dictionary.flush()
    Ola.train_dictionary("assets/words", n_grams: 3)
  end

  test "single word" do
    Dictionary.flush()
    Ola.train "balloon", n_grams: 3
    assert Ola.word()
  end

  test "word length" do
    Enum.each(3..10, fn length ->
      Enum.each(1..@num_attempts, fn _attempt ->
        assert String.length(Ola.word(length: length)) == length
      end)
    end)
  end

  test "n_grams... including beyond what we trained" do
    Enum.each(1..6, fn n_grams ->
      Enum.each(1..@num_attempts, fn _attempt ->
        assert Ola.word(n_grams: n_grams)
      end)
    end)
  end

  test "rejects n_grams below zero" do
    assert_raise ArgumentError, fn -> Ola.word(n_grams: 0) end
    assert_raise ArgumentError, fn -> Ola.word(n_grams: -20) end
  end
end
