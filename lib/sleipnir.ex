defmodule Sleipnir do
  @moduledoc """
  Documentation for `Sleipnir`.
  """

  alias Logproto.{EntryAdapter, PushRequest, StreamAdapter}
  alias Sleipnir.Timestamp

  @type labels :: list({String.t(), String.t()})

  defdelegate push(client, request), to: Sleipnir.Client

  @doc """
  Returns an entry, which is a log line/string at a given time.
  """
  @spec entry(term(), DateTime.t() | NaiveDateTime.t() | Timestamp.t()) ::
          EntryAdapter.t()
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
  """
  @spec stream(labels(), EntryAdapter.t() | list(EntryAdapter.t())) :: StreamAdapter.t()
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
          DateTime.t() | NaiveDateTime.t() | Google.Protobuf.Timestamp.t()
        ) :: StreamAdapter.t()
  def stream(line, labels, timestamp) do
    line
    |> entry(timestamp)
    |> stream(labels)
  end

  @spec request(StreamAdapter.t() | list(StreamAdapter.t())) :: PushRequest.t()
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
