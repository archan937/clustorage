# Clustorage

Elixir cluster to store and distribute data and functions by code compilation and hot loading done by a designated "loader node"

## Installation

To install Clustorage, please do the following:

  1. Add clustorage to your list of dependencies in `mix.exs`:

      ```elixir
      def deps do
        [
          {:clustorage, "~> 0.1.0", git: "https://github.com/archan937/clustorage.git"}
        ]
      end
      ```

  2. Configure your Clustorage cluster node in `config/config.exs`:

      ```elixir
      config :clustorage, name: "<your unique node name>",
        cookie: "<your secret cluster cookie>",
        loader: "<name of the designated loader node>" # not necessary in the "loader node" config file
      ```

  3. Start your supervised Clustorage node:

      ```elixir
      defmodule My.Application do
        use Application

        def start(_type, _args) do
          children = [
            Clustorage
          ]
          opts = [strategy: :one_for_one, name: My.Supervisor]
          Supervisor.start_link(children, opts)
        end
      end
      ```

## Usage

### Simple key / value data

Using Clustorage is easy, just get a value by passing a key and a function which will be invoked during the first attempt of acquiring the value.

  ```elixir
  Clustorage.get(:hello, fn -> :world end)
  :world
  ```

### Distributing functions

It is also possible to compile and hot load functions. This is also pretty straightforward:

  ```elixir
  Clustorage.call(:sum, [1, 4], fn() ->
    quote do
      fn(a, b) ->
        a + b
      end
    end
  end)
  5
  ```

(additional documentation)

## Run the Clustorage demo

This repository is provided with a small demo in which you can run three nodes within a tmux session.

The designated "loader node" within the cluster is `app1`. So when storing data, `app1` will receive a compile message. After having compiled the function, it will hot load `app2` and `app3`.

Start the demo tmux session as follows:

  ```shell
  demo/tmux.sh
  ```

NOTE: When encountering `Protocol ‘inet_tcp’: register/listen error: econnrefused` please run the following command in your console first.

  ```shell
  epmd -daemon
  ```

You can start fetching data right away:

  ```elixir
  iex(1)> Clustorage.get(:hello, fn() -> :world end)
  :world
  iex(2)> Clustorage.call(:sum, [1, 4], fn() ->
  ...(app3@192.168.0.20)1>   quote do
  ...(app3@192.168.0.20)1>     fn(a, b) ->
  ...(app3@192.168.0.20)1>       a + b
  ...(app3@192.168.0.20)1>     end
  ...(app3@192.168.0.20)1>   end
  ...(app3@192.168.0.20)1> end)
  5
  ```

Kill the tmux session as follows:

  ```shell
  tmux kill-session -t clustor
  ```

## TODO

- Write tests (sry, this project was written from scratch in a weekend :grimacing:)

## License

Copyright (c) 2018 Paul Engel, released under the MIT License

http://github.com/archan937 – http://twitter.com/archan937 – pm_engel@icloud.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
