defmodule Sleipnir do
  @moduledoc """
  Sleipnir consists of functions to create valid PushRequests to
  send to Grafana Loki, as well as a protocol for clients and a default implementation
  thereof for Tesla clients.
  This gives the user of this library flexibility in which parts they would like to use,
  as well as a quick way to start sending requests to Loki by using Tesla.

  Functions generally return the underlying Protobufs:
    * `Google.Protobuf.Timestamp`: Standard Protobuf for timestamps.
      Represented as seconds and nanoseconds encoded in Propleptic Gregorian Calendar.
      The Sleipnir.Timestamp module provides functions for manipulating and creating
      timestamps from Elixir-native types.
    * `Logproto.EntryAdapter`: An entry is a log line at a certain time
    * `Logproto.StreamAdapter`: A stream is a collection of entries under a common set of labels.
    * `Logproto.PushRequest`: A request is a collection of streams, and can be sent to Grafana Loki.
  """

  alias Logproto.{EntryAdapter, PushRequest, StreamAdapter}
  alias Sleipnir.Timestamp

  @type timestamp :: Google.Protobuf.Timestamp.t()
  @type entry :: EntryAdapter.t()
  @type stream :: StreamAdapter.t()
  @type request :: PushRequest.t()
  @typedoc ~S"""
  Loki labels are easily represented in Elixir as a list of String tuples.

    labels = [
      {"namespace", "loki"},
      {"region", "us-east-1"}
    ]
  """
  @type labels :: list({String.t(), String.t()})

  defdelegate push(client, request, opts \\ []), to: Sleipnir.Client

  @doc """
  Returns an entry, which is a log line/string at a given time.
  The timestamp can be of type DateTime, NaiveDateTime, or Google.Protobuf.Timestamp.
  If no timestamp is provided, the current time is used.


    entry1 = Sleipnir.entry("I am a log line")
    entry2 = Sleipnir.entry("I am also a log line", DateTime.utc_now())
  """
  @spec entry(term(), DateTime.t() | NaiveDateTime.t() | timestamp()) :: entry()
  def entry(line, time \\ Timestamp.now())

  def entry(line, %DateTime{} = timestamp) do
    entry(line, Timestamp.from(timestamp))
  end

  def entry(line, %NaiveDateTime{} = timestamp) do
    entry(line, Timestamp.from(timestamp))
  end

  def entry(line, %Google.Protobuf.Timestamp{} = timestamp) do
    EntryAdapter.new!(line: line, timestamp: timestamp)
  end

  @doc """
  A stream consists of one or more entries under a common set of labels.

    stream = Sleipnir.stream([entry1, entry2], [{"label", "value"}])
  """
  @spec stream(entry() | list(entry()), labels()) :: stream()
  def stream(%EntryAdapter{} = entry, labels) do
    entry
    |> List.wrap()
    |> stream(labels)
  end

  def stream(entries, labels) when is_list(entries) do
    labels = labels |> Enum.map(&to_kv/1) |> Enum.reverse() |> Enum.join(",") |> parenthesize

    StreamAdapter.new!(
      labels: labels,
      entries: sort_entries(entries)
    )
  end

  def stream(line, labels) when is_binary(line) do
    line
    |> entry()
    |> stream(labels)
  end

  @doc """
  Returns a stream for a single entry from a line and timestamp.
  To create a stream of multiple entries, take a look at stream/2.
  """
  @spec stream(
          labels(),
          String.t(),
          DateTime.t() | NaiveDateTime.t() | timestamp()
        ) :: stream()
  def stream(line, labels, timestamp) do
    line
    |> entry(timestamp)
    |> stream(labels)
  end

  @doc """
  Creates a PushRequest from one or more streams.

    request = Sleipnir.request(stream)
  """
  @spec request(stream() | list(stream())) :: request()
  def request(%StreamAdapter{} = stream) do
    stream
    |> List.wrap()
    |> request()
  end

  def request(streams) when is_list(streams) do
    PushRequest.new!(streams: streams)
  end

  defp sort_entries(%EntryAdapter{} = entry), do: [entry]

  defp sort_entries(entries) when is_list(entries) do
    entries
    |> Enum.sort_by(fn %EntryAdapter{timestamp: timestamp} -> timestamp end, &<=/2)
  end

  defp parenthesize(labels) do
    "{#{labels}}"
  end

  defp to_kv({label, value}) do
    ~s(#{label}="#{value}")
  end
end
