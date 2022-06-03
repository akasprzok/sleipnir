defmodule Sleipnir.TimestampTest do
  use ExUnit.Case
  doctest Sleipnir.Timestamp

  import Sleipnir.Timestamp

  test "can be derived from Logger time" do
    naive = ~N[2000-01-01 23:00:07]

    from_logger_format =
      from(
        {{naive.year, naive.month, naive.day},
         {naive.hour, naive.minute, naive.second, elem(naive.microsecond, 0) * 1000}}
      )

    from_naive = from(naive)
    assert :eq == compare(from_naive, from_logger_format)
  end

  test "sorts collections of timestamps correctly" do
    unbreakable = ~N[2000-01-01 23:00:07] |> from()
    super_8 = ~N[2011-08-07 08:35:33] |> from()
    endgame = ~N[2019-03-22 16:24:55] |> from()

    [unbreakable, super_8, endgame]
    |> permute()
    |> Enum.each(fn permutation ->
      assert [unbreakable, super_8, endgame] == Enum.sort(permutation, Sleipnir.Timestamp)
    end)
  end

  def permute([]), do: [[]]

  def permute(list) do
    for elem <- list, rest <- permute(list -- [elem]), do: [elem | rest]
  end
end
