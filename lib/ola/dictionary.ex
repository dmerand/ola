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
  def random_key(length \\ 1) do
    GenServer.call(__MODULE__, {:random_key, length})
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

	def handle_call({:lookup, key}, _from, %{map: map} = state) do
    value_map = Map.get(map, key, %{})

    {:reply, value_map, state}
	end

	def handle_call({:probable_next_key, key}, _from, %{map: map} = state) do
    next_key = handle_probable_next_key(map, key)

    {:reply, next_key, state}
	end

	def handle_call({:random_key, length}, _from, %{map: map} = state) do
    key = try do
      {k, _} =
        map
        |> Enum.filter(fn {k,_} -> String.length(k) == length end)
        |> Enum.random()
      k
    rescue
      _e in Enum.EmptyError ->
        {k, _} = Enum.random(map)
        k
    end

    {:reply, key, state}
	end

  @impl true
  def handle_cast({:flush}, state) do
    {:noreply, %{state | map: %{}}}
  end

	def handle_cast({:increment, key, value, amount}, %{map: map} = state) do
    value_map = Map.get(map, key, %{})
    value_probability = Map.get(value_map, value, 0) + amount 

    value_map = Map.put(value_map, value, value_probability)
    map = Map.put(map, key, value_map)

    {:noreply, %{state | map: map}}
	end

  defp handle_probable_next_key(map, key) do
    with {:ok, value_map} <- Map.fetch(map, key) do
      total_prob = Enum.reduce(value_map, 0, fn {_key, prob}, acc -> prob + acc end)
      random_index = Enum.random(0..total_prob - 1)

      {_, next_key} = Enum.reduce(value_map, {0, nil}, fn {key, prob}, {sum, int_key} ->
        case int_key do
          nil ->
            if prob + sum < random_index do
              {prob + sum, nil}
            else
              {sum, key}
            end
          _ ->
            {sum, int_key}
        end
      end)

      next_key
    else
      _ ->
        {key, _} = 
          map
          |> Enum.shuffle()
          |> Enum.find(fn {k,_v} -> String.length(k) == 1 end)
        key
    end
  end
end
