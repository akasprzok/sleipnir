defmodule Sleipnir do
  @moduledoc """
  Documentation for `Sleipnir`.
  """

  alias Google.Protobuf.Timestamp

  @type labels :: list({String.t(), String.t()})

  @spec stream(labels(), Logproto.EntryAdapter.t()) :: Logproto.StreamAdapter.t()
  def stream(labels, entries) do
    labels = labels |> Enum.map(&to_kv/1) |> Enum.join(",") |> parenthesize

    Logproto.StreamAdapter.new(
      labels: labels,
      entries: entries
    )
  end

  defp parenthesize(labels) do
    "{#{labels}}"
  end

  defp to_kv({label, value}) do
    ~s(#{label}="#{value}")
  end
end
