defmodule EighteenTest do
  use ExUnit.Case

  test "example1" do
    input = """
    #########
    #b.A.@.a#
    #########
    """

    Eighteen.solve(input) == 8
  end

  test "example 2" do
    input = """
    ########################
    #f.D.E.e.C.b.A.@.a.B.c.#
    ######################.#
    #d.....................#
    ########################
    """

    assert Eighteen.solve(input) == 86
  end

  test "example 3" do
    input = """
    #################
    #i.G..c...e..H.p#
    ########.########
    #j.A..b...f..D.o#
    ########@########
    #k.E..a...g..B.n#
    ########.########
    #l.F..d...h..C.m#
    #################
    """

    assert Eighteen.solve(input) == 136
  end
end
