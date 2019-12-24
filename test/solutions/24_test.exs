defmodule TwentyFourTest do
  use ExUnit.Case

  # test "example" do
  #   input =
  #     """
  #     ....#
  #     #..#.
  #     #..##
  #     ..#..
  #     #....
  #     """

  #   state = TwentyFour.parse(input)
  #   TwentyFour.next(state)
  #   # |> IO.inspect()
  # end

  test "pt1" do
    input =
      """
      ##...
      #.###
      .#.#.
      #....
      ..###
      """

    state = TwentyFour.parse(input)
    assert TwentyFour.iter_until_repeat(state) |> TwentyFour.sum_bio() == 18350099
  end

  test "pt2" do
    input =
      """
      ##...
      #.###
      .#.#.
      #....
      ..###
      """

    state = TwentyFourRecursive.parse(input)

    s =
      Enum.reduce((0..199), state, fn _, state ->
        TwentyFourRecursive.next(state)
      end)

    # print(s, 5..-5)

    assert s
    |> Map.values()
    |> Enum.filter(& &1 == "#")
    |> length() == 2037
  end

  def print(state, range) do
    for dep <- range do
      IO.write("\n\n\n")
      for r <- (0..4), c <- (0..4) do
        IO.write(Map.fetch!(state, {{r, c}, dep}))

        if c == 4, do: IO.write("\n")
      end
    end
  end
end
