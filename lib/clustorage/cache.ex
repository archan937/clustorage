defmodule Clustorage.Cache do
  @moduledoc """
  Documentation for Clustorage.Cache.
  """

  use GenServer

  @name :clustorage_cache

  def start_link([]) do
    GenServer.start_link(__MODULE__, %{table: nil}, [name: @name])
  end

  def get(key, fun, type, compile \\ false) do
    case GenServer.call(@name, {:get, key}) do
      :nil ->
        value = fun.()
        GenServer.cast(@name, {:put, key, value})
        if compile, do: Clustorage.Node.compile(key, value, type)
        value
      value ->
        value
    end
  end

  def delete(key) do
    GenServer.cast(@name, {:delete, key})
  end

  def init(state) do
    send self(), :init
    {:ok, state}
  end

  def handle_info(:init, state) do
    state = create_ets_table(state)
    {:noreply, state}
  end

  def handle_call({:get, key}, _from, %{table: table} = state) do
    value =
      case :ets.lookup(table, key) do
        [{^key, value}] -> value
        [] -> :nil
      end
    {:reply, value, state}
  end

  def handle_cast({:put, key, value}, %{table: table} = state) do
    :ets.insert(table, {key, value})
    {:noreply, state}
  end

  def handle_cast({:delete, key}, %{table: table} = state) do
    :ets.delete(table, key)
    {:noreply, state}
  end

  defp create_ets_table(state) do
    %{state | table: :ets.new(:clustorage, [])}
  end

end
