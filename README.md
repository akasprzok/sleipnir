![main](https://github.com/akasprzok/sleipnir/actions/workflows/main.yml/badge.svg?branch=main)
[![Hex](https://img.shields.io/hexpm/v/sleipnir.svg)](https://hex.pm/packages/sleipnir/)
[![Hex Docs](https://img.shields.io/badge/hex-docs-informational.svg)](https://hexdocs.pm/sleipnir/)
![License](https://img.shields.io/hexpm/l/sleipnir)
[![Coverage Status](https://coveralls.io/repos/github/akasprzok/sleipnir/badge.svg?branch=main)](https://coveralls.io/github/akasprzok/sleipnir?branch=main)

# Sleipnir

A client for pushing logs to Grafana Loki.

## Installation

The package can be installed
by adding `sleipnir` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sleipnir, "~> 0.1.1"}
  ]
end
```

Documentation may be found at <https://hexdocs.pm/sleipnir>.

## Usage

The `Sleipnir` module contains functions for creating Loki requests from your data, based on Grafana's protobufs. The important parts are:

* `Entries`: timestamped strings
* `Streams`: collections of entries under a common set of labels.
* `PushRequests`: collections of streams, all pushed to Loki as a single request.

Here's an example:

```elixir
entries = [
  Sleipnir.entry("I am a log line"),
  Sleipnir.entry("I am another log line")
]
labels = [
  {"cluster", "ops-cluster-1"},
  {"namespace", "loki-dev"}
]
stream = Sleipnir.stream(entries, labels)
request = Sleipnir.request(stream)
```

To send the requests to Loki, Sleipnir includes a Tesla client that aims to provide sensible defaults.

```elixir
client = Sleipnir.Client.Tesla.new("http://localhost:3100", org_id: "tenant1")

{:ok, %{status: 204}} = Sleipnir.push(client, request)
```

## Customizing the Client

Custom clients can be implemented via the `[Sleipnir.Client](lib/sleipnir/client.ex)` protocol.

A default implementation is provided for the `[Tesla.Client](/lib/sleipnir/client/tesla.ex) struct` which zips the push request and sends it to the standard `/loki/api/v1/push` path.

Also included is the `[Sleipnir.Client.Test client](lib/sleipnir/client/test.ex)` which sends any requests pushed to it to the provided pid. Useful for testing without the need for bypass or Tesla.Mock.