defmodule Ola do
  @moduledoc """
  Makes fake words that sound like real words!
  """

  alias Ola.Dictionary

  @doc """
  Returns a fake word

  ## Options
  
  You can pass the following `opts`:

  - `length` (default: 3..16) - desired word length
  - `n_grams` (default: 1) - size of n_gram window (anything up to the size you used when parsing)
  """
  def word(opts \\ []) do
    length = Keyword.get(opts, :length, Enum.random(3..16))
    n_grams = Keyword.get(opts, :n_grams, 1)

    max_n_grams = Enum.max_by(Dictionary.all(), fn {k, _v} ->
      String.length(k)
    end)

    n_grams = if n_grams > max_n_grams do
      max_n_grams
    else
      n_grams
    end

    Enum.reduce(0..length - n_grams - 1, Dictionary.random_key(n_grams), fn _i, word ->
      window = String.slice(word, (String.length(word) - n_grams)..-1)
      next_key = Dictionary.probable_next_key(window)

      word <> next_key
    end)
  end

  @doc """
  Trains a single word into the probability dictionary

  ## Options
  
  You can pass the following `opts`:

  - `n_grams` (default: 1) - size of n_gram window to use for analysis
  """
  def train(word, opts \\ []) when is_binary(word) do
    n_grams = Keyword.get(opts, :n_grams, 1)
    word = String.trim(word)
    length = String.length(word)
    n_grams = if n_grams > length do
      length
    else
      n_grams
    end

    Enum.each(1..n_grams, fn gram ->
      Enum.each(0..(length - gram - 1), fn i ->
        segment = String.slice(word, i, gram + 1)
        segment_length = String.length(segment)
        if segment_length > 1 && segment_length > gram do
          <<key::binary-size(gram), next::binary>> = segment
          Dictionary.increment(key, next)
        end
      end)
    end)
  end

  @doc """
  Parse a dictionary file (newline-separated strings)

  ## Options
  
  You can pass the following `opts`:

  - `n_grams` (default: 1) - size of n_gram window to use for analysis.
  """
  def train_dictionary(filename, opts \\ []) do
    n_grams = Keyword.get(opts, :n_grams, 1)

    File.stream!(filename)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&(train(&1, n_grams: n_grams)))
    |> Stream.run()
  end
end
