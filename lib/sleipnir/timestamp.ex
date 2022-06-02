defmodule Sleipnir.Timestamp do
  @moduledoc """
  Helpers centered around the use of Google.Protobuf.Timestamp
  """

  alias Google.Protobuf.Timestamp

  @spec from(Logger.Formatter.time() | NaiveDateTime.t()) :: Timestamp.t()
  def from({{yy, mm, dd}, {hh, mi, ss, ms}}) do
    NaiveDateTime.from_erl!({{yy, mm, dd}, {hh, mi, ss}, {ms, 3}})
    |> from()
  end

  :snappyer

  def from(%NaiveDateTime{} = time) do
    {seconds, microseconds} = time
    |> NaiveDateTime.to_gregorian_seconds()
    Timestamp.new!(seconds: seconds, nanoseconds: microseconds*1000)
  end
end
