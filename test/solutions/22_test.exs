defmodule TwentyTwoTest do
  use ExUnit.Case

  test "example" do
    deck = (0..9) |> Enum.into([])

    assert TwentyTwo.solve(deck, "cut 3") == [3, 4, 5, 6, 7, 8, 9, 0, 1, 2]
    assert TwentyTwo.solve(deck, "cut -3") == [7, 8, 9, 0, 1, 2, 3, 4, 5, 6]
    assert TwentyTwo.solve(deck, "deal with increment 3") == [0, 7, 4, 1, 8, 5, 2, 9, 6, 3]
    assert TwentyTwo.solve(deck, "deal into new stack") == [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]

    input = """
    deal into new stack
    cut -2
    deal with increment 7
    cut 8
    cut -4
    deal with increment 7
    cut 3
    deal with increment 9
    deal with increment 3
    cut -1
    """
    assert TwentyTwo.solve(deck, input) == [9, 2, 5, 8, 1, 4, 7, 0, 3, 6]


    input = """
    deal with increment 7
    deal with increment 9
    cut -2
    """
    assert TwentyTwo.solve(deck, input) == [6, 3, 0, 7, 4, 1, 8, 5, 2, 9]

    input = """
    deal with increment 7
    deal into new stack
    deal into new stack
    """
    assert TwentyTwo.solve(deck, input) == [0, 3, 6, 9, 2, 5, 8, 1, 4, 7]
  end

  test "pt1" do
    input = File.read!("22.in") |> String.trim()
    deck = (0..10006) |> Enum.into([])
    assert Enum.find_index(deck, & &1 == 2019) == 2019

    deck = TwentyTwo.solve(deck, input)
    # deck |> IO.inspect(limit: :infinity)
    assert Enum.find_index(deck, & &1 == 2019) == 4684
  end

  test "pt2" do
    input = File.read!("22.in") |> String.trim()

    Enum.each((10006..10006), fn max ->
      deck = (0..max) |> Enum.into([])

      deck = TwentyTwo.solve(deck, input)
      first = Enum.at(deck, 2020)
      if length(deck) - 1 == max do
        if first == max do
          IO.puts "SAME: #{max}, #{first}"
        else
          IO.puts "#{max}, #{first}"
        end
      end
    end)

    # 100 => 86
    # 101 => 94
    # 102 => 81
    # 103 => 93
  end
end
