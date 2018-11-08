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
    if Clustorage.Compiler.compiled?(key) do
      get_compiled(key)
    else
      get_cached(key, fun)
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
    Clustorage.Cache.get(key, fun, true)
  end

end
