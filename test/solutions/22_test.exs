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

  test "pt1 (rewrote for pt2 based on reddit thread)" do
    input = File.read!("22.in") |> String.trim()
    deck = {offset, increment} = TwentyTwo.solve_2(10007, input, 1)
    assert offset = 10053119434732068746930192007922504334219971109549206493954398063905060114936306625769742478339344360889755819120565363834100219006540476897087013
    assert increment = 7663208623171456538450488294964240044656124160182652527660130919309173576717976079401113364929105526531315727625505984742485415936819200000000

    assert Enum.find(0..10006, fn i ->
      get(offset, increment, i, 10007) == 2019
    end) == 4684

    # deck = (0..10006) |> Enum.into([])
    # assert Enum.find_index(deck, & &1 == 2019) == 2019

    # deck = TwentyTwo.solve_2(deck, input)
    # # deck |> IO.inspect(limit: :infinity)
    # assert Enum.find_index(deck, & &1 == 2019) == 4684
  end

  # Followed along with https://www.reddit.com/r/adventofcode/comments/ee0rqi/2019_day_22_solutions/fbnkaju/ to get
  # the right answer. Had to implement pow/3 that python gives for free into Elixir.
  test "pt2" do
    input = File.read!("22.in") |> String.trim()
    {offset, increment} = TwentyTwo.solve_2(119315717514047, input, 101741582076661)

    assert get(offset, increment, 2020, 119315717514047) == 452290953297
  end

  def get(offset, increment, i, size) do
    rem((offset + i * increment), size)
  end
end
