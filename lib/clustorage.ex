defmodule Clustorage do
  @moduledoc """
  Documentation for Clustorage.
  """

  use Supervisor

  def start_link([]) do
    Supervisor.start_link(__MODULE__, [], [])
  end

  def init(_state) do
    children = [
      Clustorage.Compiler,
      Clustorage.Cache,
      Clustorage.Node
    ]
    opts = [strategy: :one_for_all, name: Clustorage.Supervisor]
    Supervisor.init(children, opts)
  end

  def get(key, fun) do
    key = normalize_key(key)
    if Clustorage.Compiler.compiled?(key, :get) do
      get_compiled(key)
    else
      get_cached(key, fun)
    end
  end

  def call(key, args, fun) do
    key = normalize_key(key)
    if Clustorage.Compiler.compiled?(key, :call) do
      call_compiled(key, args)
    else
      call_cached(key, args, fun)
    end
  end

  defp normalize_key(key) do # TODO: Add validation
    key
    |> List.wrap()
    |> Enum.join(".")
  end

  defp get_compiled(key) do
    Clustorage.Compiler.get(key)
  end

  defp get_cached(key, fun) do
    Clustorage.Cache.get(key, fun, :get, true)
  end

  defp call_compiled(key, args) do
    Clustorage.Compiler.call(key, args)
  end

  defp call_cached(key, args, fun) do
    key
    |> Clustorage.Cache.get(fun, :call, true)
    |> Code.eval_quoted()
    |> elem(0)
    |> apply(args)
  end

end
