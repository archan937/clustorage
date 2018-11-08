defmodule Clustorage.Compiler do
  @moduledoc """
  Documentation for Clustorage.Compiler.
  """

  use GenServer

  @name :clustorage_compiler

  def start_link([]) do
    GenServer.start_link(__MODULE__, nil, [name: @name])
  end

  def init(state), do: {:ok, state}

  def compiled?(key) do
    key
    |> to_module()
    |> function_exported?(:value, 0)
  end

  def compile(key, value) do
    module = to_module(key)
    purge(module)

    [{^module, binary}] =
      module
      |> to_quoted(value)
      |> Code.compile_quoted()

    Clustorage.Node.hot_load(key, module, binary)
    :ok
  end

  def hot_load(key, module, binary) do
    purge(module)
    load_binary(module, binary)
    Clustorage.Cache.delete(key)
    :ok
  end

  def get(key) do
    to_module(key).value()
  end

  defp purge(module) do
    :code.purge(module)
    :code.delete(module)
  end

  defp load_binary(module, binary) do
    :code.load_binary(module, nil, binary)
  end

  defp to_module(key) do
    :"Elixir.Clustorage:#{key}"
  end

  defp to_quoted(module, value) do
    quote do
      defmodule unquote(module) do
        def value do
          unquote(Macro.escape(value))
        end
      end
    end
  end

end
