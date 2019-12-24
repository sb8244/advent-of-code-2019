defmodule TwentyFourTest do
  use ExUnit.Case

  test "example" do
    input =
      """
      ....#
      #..#.
      #..##
      ..#..
      #....
      """

    state = TwentyFour.parse(input)
    state2 = TwentyFour.next(state)

    # IO.inspect state2
  end

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
end
