defmodule Ola do
  @moduledoc """
  Makes fake words that sound like real words!
  """

  alias Ola.Dictionary

  @doc """
  Returns a fake word
  """
  def word(opts \\ []) do
    length = Keyword.get(opts, :length, Enum.random(3..20))
    Enum.reduce(0..length - 1, Dictionary.random_key(), fn _i, word ->
      word <> Dictionary.probable_next_key(String.at(word, -1))
    end)
  end

  @doc """
  Parse a single word into the probability dictionary
  """
  def parse(word) when is_binary(word) do
    word
    |> String.trim()
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.each(fn {key, index} ->
      with next when not is_nil(next) <- String.at(word, index + 1) do
        Dictionary.increment(key, next)
      end
    end)
  end

  @doc """
  Parse a dictionary file (newline-separated strings)
  """
  def parse_dictionary(filename) do
    File.stream!(filename)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse/1)
    |> Stream.run()
  end
end
