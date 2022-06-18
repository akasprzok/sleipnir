defmodule Sleipnir do
  @moduledoc """
  Documentation for `Sleipnir`.
  """

  alias Logproto.{EntryAdapter, PushRequest, StreamAdapter}
  alias Sleipnir.Timestamp

  @type labels :: list({String.t(), String.t()})

  @spec entry(term(), DateTime.t() | NaiveDateTime.t() | Google.Protobuf.Timestamp.t()) ::
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

  @spec stream(labels(), EntryAdapter.t()) :: StreamAdapter.t()
  def stream(labels, entries) do
    labels = labels |> Enum.map(&to_kv/1) |> Enum.reverse() |> Enum.join(",") |> parenthesize

    StreamAdapter.new!(
      labels: labels,
      entries: sort_entries(entries)
    )
  end

  @spec request(StreamAdapter.t() | list(StreamAdapter.t())) :: PushRequest.t()
  def request(%StreamAdapter{} = stream) do
    request([stream])
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
