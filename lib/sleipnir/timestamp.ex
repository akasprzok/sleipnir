defmodule Sleipnir.Timestamp do
  @moduledoc """
  Helpers centered around the use of Google.Protobuf.Timestamp
  """

  alias Google.Protobuf.Timestamp

  defdelegate new, to: Timestamp, as: :new

  @spec from(Logger.Formatter.time() | NaiveDateTime.t()) :: Timestamp.t()
  def from({{yy, mm, dd}, {hh, mi, ss, ms}}) do
    NaiveDateTime.from_erl!({{yy, mm, dd}, {hh, mi, ss}}, {ms, 3})
    |> from()
  end

  def from(%DateTime{} = time) do
    {seconds, microseconds} =
      time
      |> DateTime.to_gregorian_seconds()

    Timestamp.new!(seconds: seconds, nanos: microseconds * 1000)
  end

  def from(%NaiveDateTime{} = time) do
    {seconds, microseconds} =
      time
      |> NaiveDateTime.to_gregorian_seconds()
      |> to_epoch()

    Timestamp.new!(seconds: seconds, nanos: microseconds * 1000)
  end

  @spec now :: Timestamp.t()
  def now do
    NaiveDateTime.utc_now() |> from()
  end

  def compare(%Timestamp{seconds: seconds1, nanos: nanos1}, %Timestamp{
        seconds: seconds2,
        nanos: nanos2
      }) do
    case {{seconds1, nanos1}, {seconds2, nanos2}} do
      {first, second} when first > second -> :gt
      {first, second} when first < second -> :lt
      _ -> :eq
    end
  end

  defp to_epoch({gregorian_seconds, microseconds}) when is_integer(gregorian_seconds) do
    {gregorian_seconds - 62_167_219_200, microseconds}
  end
end
