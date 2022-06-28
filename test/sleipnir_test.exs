defmodule SleipnirTest do
  use ExUnit.Case
  doctest Sleipnir

  import Sleipnir
  alias Google.Protobuf.Timestamp
  alias Logproto.{EntryAdapter, StreamAdapter}

  describe "stream/1" do
    test "constructs a stream adapter with sorted entries" do
      labels = %{
        "service" => "sleipnir",
        "environment" => "dev"
      }

      line =
        EntryAdapter.new(
          line: "I am a line",
          timestamp: %Timestamp{
            seconds: 12_345,
            nanos: 123
          }
        )

      another_line =
        EntryAdapter.new(
          line: "I am another line",
          timestamp: %Timestamp{
            seconds: 123_456,
            nanos: 1234
          }
        )

      assert stream([another_line, line], labels) == %StreamAdapter{
               labels: ~s({service="sleipnir",environment="dev"}),
               entries: [line, another_line]
             }
    end
  end
end
