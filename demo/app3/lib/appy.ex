defmodule Appy do
  @moduledoc """
  Documentation for Appy.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Appy.hello
      :world

  """
  def hello do
    :world
  end

  def benchmark do
    n = 500_000
    fun = fn ->
      [
        %{
          "action" => "sent",
          "data" => %{
            "channel" => "email",
            "message" => %{
              "campaign" => 1,
              "editor_id" => 1,
              "group" => 2,
              "list_type" => "regular",
              "schedule" => 4,
              "shortener" => "default",
              "target_data" => %{
                "birthday" => "1982-06-09T15:00:00",
                "businessunit" => "Board",
                "locale" => "eng",
                "location_data" => %{
                  "city" => "São Paulo",
                  "city_data" => %{"mayor" => "John Snow", "population" => 30000000}
                },
                "nome" => "Pedro",
                "role" => "CTO"
              }
            },
            "provider" => "sendgrid"
          },
          "id" => 8,
          "inserted_at" => "2018-04-02 18:07:52.260159",
          "key" => "cGhpc2h4fDF8NHwyfHJlZ3"
        }
      ]
    end

    fn ->
      Clustorage.Cache.delete("hello")
      for _n <- 0..n do
        Clustorage.Cache.get("hello", fun)
      end
    end
    |> :timer.tc
    |> elem(0)
    |> Kernel./(1_000_000)
    |> IO.inspect(label: "ETS data")

    fn ->
      Clustorage.Cache.delete("hello")
      for _n <- 0..n do
        Clustorage.get("hello", fun)
      end
    end
    |> :timer.tc
    |> elem(0)
    |> Kernel./(1_000_000)
    |> IO.inspect(label: "Compiled data")

    nil
  end

end
