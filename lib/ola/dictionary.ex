defmodule Ola.Dictionary do
  @moduledoc """
  Service for storage + retrieval of probability data.
  """

  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Show the whole probability table (mostly for testing)
  """
  def all do
    GenServer.call(__MODULE__, {:all})
  end

  @doc """
  Increment a probability `value` for a given `key`
  """
  def increment(key, value, amount \\ 1) do
    GenServer.call(__MODULE__, {:increment, key, value, amount})
  end

  @doc """
  Lookup the current set of `value` probabilities for a given `key`
  """
  def lookup(key) do
    GenServer.call(__MODULE__, {:lookup, key})
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
  def random_key() do
    GenServer.call(__MODULE__, {:random_key})
  end

  ## Server callbacks

  @impl true
  def init(_opts) do
    {:ok, %{map: %{}}}
  end

	@impl true
  def handle_call({:all}, _from, %{map: map} = state) do
    {:reply, map, state}
  end

	def handle_call({:increment, key, value, amount}, _from, %{map: map} = state) do
    value_map = Map.get(map, key, %{})
    value_probability = Map.get(value_map, value, 0) + amount 

    value_map = Map.put(value_map, value, value_probability)
    map = Map.put(map, key, value_map)

    {:reply, map, %{state | map: map}}
	end

	def handle_call({:lookup, key}, _from, %{map: map} = state) do
    value_map = Map.get(map, key, %{})

    {:reply, value_map, state}
	end

	def handle_call({:probable_next_key, key}, _from, %{map: map} = state) do
    with {:ok, value_map} <- Map.fetch(map, key) do
      total_prob = Enum.reduce(value_map, 0, fn {_key, prob}, acc -> prob + acc end)
      index = Enum.random(0..total_prob - 1)
      {_, next_key} = Enum.reduce(value_map, {0, nil}, fn {key, prob}, {sum, int_key} ->
        case int_key do
          nil ->
            if prob + sum < index do
              {prob + sum, nil}
            else
              {sum, key}
            end
          _ ->
            {sum, int_key}
        end
      end)

      {:reply, next_key, state}
    else
      _ ->
        {:reply, nil, state}
    end
	end

	def handle_call({:random_key}, _from, %{map: map} = state) do
    {key, _} = Enum.random(map)

    {:reply, key, state}
	end
end
