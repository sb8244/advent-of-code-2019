defmodule SixTest do
  use ExUnit.Case

  test "example" do
    input =
      """
      COM)B
      B)C
      C)D
      D)E
      E)F
      B)G
      G)H
      D)I
      E)J
      J)K
      K)L
      """ |> String.trim()

    assert Six.solve(input) == 42

    input =
      """
      COM)B
      B)C
      C)D
      D)E
      E)F
      B)G
      G)H
      D)I
      E)J
      J)K
      K)L
      K)YOU
      I)SAN
      """ |> String.trim()

    assert Six.shortest(input) == 4
  end

  test "pt1" do
    input = File.read!("6.in") |> String.trim()
    assert Six.solve(input) == 158090
  end

  test "pt2" do
    input = File.read!("6.in") |> String.trim()
    assert Six.shortest(input) == 241
  end
end
