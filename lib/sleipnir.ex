defmodule Sleipnir do
  @moduledoc """
  Documentation for `Sleipnir`.
  """

  alias Logproto.{EntryAdapter, PushRequest, StreamAdapter}

  @type labels :: list({String.t(), String.t()})
  @type request :: binary()

  @spec stream(labels(), EntryAdapter.t()) :: StreamAdapter.t()
  def stream(labels, entries) do
    labels = labels |> Enum.map(&to_kv/1) |> Enum.reverse() |> Enum.join(",") |> parenthesize

    StreamAdapter.new(
      labels: labels,
      entries: sort_entries(entries)
    )
  end

  @spec pack(StreamAdapter.t() | list(StreamAdapter.t())) :: request()
  def pack(%StreamAdapter{} = stream) do
    pack([stream])
  end

  def pack(streams) when is_list(streams) do
    {:ok, packed_request} =
      PushRequest.new(streams: streams)
      |> PushRequest.encode()
      |> :snappyer.compress()

    packed_request
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
