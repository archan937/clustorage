defmodule Clustorage.Node do
  @moduledoc """
  Documentation for Clustorage.Node.
  """

  use GenServer

  @name :clustorage_node

  def start_link([]) do
    GenServer.start_link(__MODULE__, %{nodes: MapSet.new()}, [name: @name])
  end

  def compile(key, value) do
    GenServer.cast(@name, {:compile, key, value})
  end

  def hot_load(key, module, binary) do
    GenServer.cast(@name, {:hot_load, key, module, binary})
  end

  def init(state) do
    send self(), :init
    {:ok, state}
  end

  def handle_info(:init, state) do
    start_node()
    set_cookie()
    monitor_nodes()
    connect(state)
    {:noreply, state}
  end

  def handle_info({:nodeup, name}, %{nodes: nodes} = state) do
    nodes = MapSet.put(nodes, name)
    {:noreply, %{state | nodes: nodes}}
  end

  def handle_info({:nodedown, name}, %{nodes: nodes} = state) do
    nodes = MapSet.delete(nodes, name)
    state = %{state | nodes: nodes}
    connect(state)
    {:noreply, state}
  end

  def handle_cast(:connect, state) do
    connect(state)
    {:noreply, state}
  end

  def handle_cast({:compile, key, value}, state) do
    Node.spawn(loader(), Clustorage.Compiler, :compile, [key, value])
    {:noreply, state}
  end

  def handle_cast({:hot_load, key, module, binary}, state) do
    if loader?() do
      Node.list()
      |> Enum.each(fn node ->
        Node.spawn(node, Clustorage.Compiler, :hot_load, [key, module, binary])
      end)
    end
    {:noreply, state}
  end

  defp name, do: Application.fetch_env!(:clustorage, :name)

  defp start_node do
    nodename()
    |> Node.start(:longnames)
  end

  defp nodename(), do: nodename(nil)
  defp nodename(nil), do: nodename(name() || hostname())
  defp nodename(name) do
    if name |> to_string() |> String.contains?("@") do
      name
    else
      "#{name}@#{ip()}"
    end
    |> String.to_atom()
  end

  defp hostname do
    {:ok, hostname} = :inet.gethostname()
    hostname
  end

  defp ip do
    {:ok, [{ip, _, _}, _]} = :inet.getif()
    ip
    |> Tuple.to_list()
    |> Enum.join(".")
  end

  defp set_cookie do
    :clustorage
    |> Application.fetch_env!(:cookie)
    |> String.to_atom()
    |> Node.set_cookie()
  end

  defp monitor_nodes, do: :net_kernel.monitor_nodes(true)

  defp connect(%{nodes: nodes}) do
    unless loader?() || MapSet.member?(nodes, loader()) || Node.connect(loader()) do
      Process.sleep(2500)
      GenServer.cast(@name, :connect)
    end
  end

  defp loader?, do: loader?(nodename())
  defp loader?(nodename), do: nodename == loader()

  defp loader do
    :clustorage
    |> Application.get_env(:loader, nil)
    |> nodename()
  end

end
