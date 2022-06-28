![main](https://github.com/akasprzok/sleipnir/actions/workflows/main.yml/badge.svg?branch=main)
[![Hex](https://img.shields.io/hexpm/v/sleipnir.svg)](https://hex.pm/packages/sleipnir/)
[![Hex Docs](https://img.shields.io/badge/hex-docs-informational.svg)](https://hexdocs.pm/sleipnir/)
![License](https://img.shields.io/hexpm/l/sleipnir)
[![Coverage Status](https://coveralls.io/repos/github/akasprzok/sleipnir/badge.svg?branch=main)](https://coveralls.io/github/akasprzok/sleipnir?branch=main)

# Sleipnir

A Loki client.

## Installation

The package can be installed
by adding `sleipnir` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sleipnir, "~> 0.1.0"}
  ]
end
```

Documentation may be found at <https://hexdocs.pm/sleipnir>.

## Usage

Currently only supports the Loki push API.

First, get a client:

```elixir
client = Sleipnir.client("http://localhost:3100", org_id: "tenant1")
```

Then, create a PushRequest and push it:

```elixir
request = "I am a log" |> Sleipnir.entry() |> Sleipnir.stream([{"service", "xyz"}]) |> Sleipnir.request()
Sleipnir.Client.push(client, request)
```

There are a variety of ways to create a request. Consult the docs for more info!