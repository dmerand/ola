defmodule Ola do
  @moduledoc """
  Makes fake words that sound like real words!

  `Ola` uses [Markov chains](https://setosa.io/ev/markov-chains/), trained on a given word (`train/2`) or dictionary of words (`train_dictionary/2`), to determine statistically-likely combinations of letters. 
  
  One nice thing about the Markov chain approach is that it can be trained on a dictionary in any language (or combination of languages), and will spit out appropriate-sounding words.

  ## A Note about N-Grams
  
  "N-grams" are the number of combined letters that you look at when determining statistical letter combination likelihoods. These will be used as "windows" later when generating words. Training with a higher `n_grams` value creates more keys and generates a larger map of statistical probability.

  For example:

      Ola.train("balloon", n_grams: 3)

      # The list of letter groups that are followed by other letters
      Ola.Dictionary.keys()
      %{
        1 => #MapSet<["a", "b", "l", "o"]>,
        2 => #MapSet<["al", "ba", "ll", "lo", "oo"]>,
        3 => #MapSet<["all", "bal", "llo", "loo"]>,
      }

      # The probability count for each letter that could follow
      Ola.Dictionary.map()
      %{
        "a" => %{"l" => 1},
        "al" => %{"l" => 1},
        "all" => %{"o" => 1},
        "b" => %{"a" => 1},
        "ba" => %{"l" => 1},
        "bal" => %{"l" => 1},
        "l" => %{"l" => 1, "o" => 1},
        "ll" => %{"o" => 1},
        "llo" => %{"o" => 1},
        "lo" => %{"o" => 1},
        "loo" => %{"n" => 1},
        "o" => %{"n" => 1, "o" => 1},
        "oo" => %{"n" => 1}
      }

      # Now generate a fake word from our training set:
      Ola.word()
      "loon"
  
  Higher n-gram values allow for more accurate words, up to a certain point. The larger your values, the larger pieces-of-words that will be used for generating random values. However, if the `n_grams` value is higher than the average word length in your dictionary, obviously there will be no letter groups with `n_gram` sizes that large. In addition, if you only trained `Ola` using n-gram sizes up to 3, passing larger values such as 4, 5, 6, etc. won't make a difference.
  """

  alias Ola.Dictionary

  @doc """
  Returns a fake word that sounds like a real word!

  Note that you must train Ola on some words first using `train/2` or `train_dictionary/2`.

  ## Options
  
  You can pass the following `opts`:

  - `length` (default: 3..16) - desired word length
  - `n_grams` (default: 1) - size of n_gram window. Anything will work, but it's really only going to work well for sizes up to the amount you have previously trained. Anything above what you've trained will fall back to n_gram sizes that you did use during training.
  """
  def word(opts \\ []) do
    length = Keyword.get(opts, :length, Enum.random(3..16))
    n_grams = set_max(Keyword.get(opts, :n_grams, 1))

    Enum.reduce(0..length - n_grams - 1, Dictionary.random_key(n_grams), fn _i, word ->
      next_key = narrowing_window(word, n_grams)
      word <> next_key
    end)
  end

  @doc """
  Trains a single word into the probability dictionary

  ## Options
  
  You can pass the following `opts`:

  - `n_grams` (default: 1) - size of n_gram window to use for training

  """
  def train(word, opts \\ []) when is_binary(word) do
    n_grams = Keyword.get(opts, :n_grams, 1)
    word = String.trim(word)
    length = String.length(word)

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

  - `n_grams` (default: 1) - size of n_gram window to use for training.
  """
  def train_dictionary(filename, opts \\ []) do
    n_grams = Keyword.get(opts, :n_grams, 1)

    File.stream!(filename)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&(train(&1, n_grams: n_grams)))
    |> Stream.run()
  end

  defp narrowing_window(word, n_grams) when n_grams > 0 do
    key = String.slice(word, (String.length(word) - n_grams)..-1)
    case Dictionary.probable_next_key(key) do
      "" -> narrowing_window(word, n_grams - 1)
      pnk -> pnk
    end
  end

  defp narrowing_window(_word, n_grams) when n_grams <= 0, do: ""

  defp set_max(n_grams) when n_grams > 0 do
    {max_n_grams, _} = Enum.max(Dictionary.keys())

    if n_grams > max_n_grams do
      max_n_grams
    else
      n_grams
    end
  end

  defp set_max(n_grams) when n_grams <= 0 do
    raise ArgumentError, "n_grams must be positive"
  end
end
