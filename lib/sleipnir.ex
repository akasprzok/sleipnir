defmodule Sleipnir do
  @moduledoc """
  Documentation for `Sleipnir`.
  """

  alias Logproto.{EntryAdapter, StreamAdapter}

  @type labels :: list({String.t(), String.t()})

  @spec stream(labels(), EntryAdapter.t()) :: StreamAdapter.t()
  def stream(labels, entries) do
    labels = labels |> Enum.map(&to_kv/1) |> Enum.reverse() |> Enum.join(",") |> parenthesize

    StreamAdapter.new(
      labels: labels,
      entries: sort_entries(entries)
    )
  end

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
