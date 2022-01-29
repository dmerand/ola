defmodule Ola.Dictionary do
  @moduledoc """
  Service for storage + retrieval of probability data.
  """

  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Flush the existing training/probability map
  """
  def flush do
    GenServer.cast(__MODULE__, {:flush})
  end

  @doc """
  Increment a probability `value` for a given `key`
  """
  def increment(key, value, amount \\ 1) do
    GenServer.cast(__MODULE__, {:increment, key, value, amount})
  end

  @doc """
  Show all available dictionary keys
  """
  def keys do
    GenServer.call(__MODULE__, {:keys})
  end

  @doc """
  Lookup the current set of `value` probabilities for a given `key`
  """
  def lookup(key) do
    GenServer.call(__MODULE__, {:lookup, key})
  end

  @doc """
  Show the whole probability table (mostly for testing)
  """
  def map do
    GenServer.call(__MODULE__, {:map})
  end

  @doc """
  Given a key, returns a statistically-probable next key
  """
  def probable_next_key(key) do
    GenServer.call(__MODULE__, {:probable_next_key, key})
  end

  @doc """
  Returns a random key from the map
  """
  def random_key(length \\ 1) do
    GenServer.call(__MODULE__, {:random_key, length})
  end

  ## Server callbacks

  @impl true
  def init(_opts) do
    {:ok, %{map: %{}, keys: %{}}}
  end

	@impl true
	def handle_call({:keys}, _from, %{keys: keys} = state) do
    {:reply, keys, state}
	end

	def handle_call({:lookup, key}, _from, %{map: map} = state) do
    probability_map = Map.get(map, key, %{})

    {:reply, probability_map, state}
	end

  def handle_call({:map}, _from, %{map: map} = state) do
    {:reply, map, state}
  end

	def handle_call({:probable_next_key, key}, _from, %{map: map} = state) do
    next_key = 
      with {:ok, value_map} <- Map.fetch(map, key),
           {cumulative_sums, total_prob} = Enum.map_reduce(value_map, 0, fn {_key, prob}, sum -> {prob + sum, prob + sum} end),
           random_prob = Enum.random(1..total_prob),
           {_sum, key_index} = Enum.find(Enum.with_index(cumulative_sums), fn {sum, _index} -> sum >= random_prob end),
           {key, _prob} = Enum.at(value_map, key_index) do
        key
    else
      _ -> ""
    end

    {:reply, next_key, state}
	end

	def handle_call({:random_key, length}, _from, %{keys: keys} = state) do
    key = diminishing_random_key(keys, length)

    {:reply, key, state}
	end

  @impl true
  def handle_cast({:flush}, state) do
    {:noreply, %{state | map: %{}, keys: %{}}}
  end

	def handle_cast({:increment, key, value, amount}, %{map: map, keys: keys} = state) do
    value_map = Map.get(map, key, %{})
    value_probability = Map.get(value_map, value, 0) + amount 
    value_map = Map.put(value_map, value, value_probability)
    map = Map.put(map, key, value_map)

    key_length = String.length(key)
    keys = case Map.fetch(keys, key_length) do
      :error -> 
        Map.put(keys, key_length, MapSet.new([key]))
      {:ok, mapset} ->
        Map.put(keys, key_length, MapSet.put(mapset, key))
    end

    {:noreply, %{state | map: map, keys: keys}}
	end

  defp diminishing_random_key(keys, length) do
    case Map.fetch(keys, length) do
      :error ->
        if length == 1 do
          ""
        else
          diminishing_random_key(keys, length - 1)
        end
      {:ok, matching_keys} ->
        Enum.random(matching_keys)
    end
  end
end
