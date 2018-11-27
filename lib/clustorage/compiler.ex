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

  def compiled?(key, :get) do
    key
    |> to_module()
    |> function_exported?(:get, 0)
  end

  def compiled?(key, :call) do
    key
    |> to_module()
    |> function_exported?(:call, 1)
  end

  def compile(key, arg, type) do
    module = to_module(key)
    purge(module)

    [{^module, binary}] =
      module
      |> to_quoted(arg, type)
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
    to_module(key).get()
  end

  def call(key, args) do
    to_module(key).call(args)
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

  defp to_quoted(module, value, :get) do
    quote do
      defmodule unquote(module) do
        def get do
          unquote(Macro.escape(value))
        end
      end
    end
  end

  defp to_quoted(module, ast, :call) do
    quote do
      defmodule unquote(module) do
        def call(args) do
          apply(unquote(ast), args)
        end
      end
    end
  end

end
