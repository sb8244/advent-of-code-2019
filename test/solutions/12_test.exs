defmodule TwelveTest do
  use ExUnit.Case

  test "example" do
    assert Twelve.solve(%{
      a: {[-1, 0, 2], [0, 0, 0]},
      b: {[2, -10, -7], [0, 0, 0]},
      c: {[4, -8, 8], [0, 0, 0]},
      d: {[3, 5, -1], [0, 0, 0]}
    }, 10) == 179
  end

  test "pt1" do
    assert Twelve.solve(%{
      a: {[6, -2, -7], [0, 0, 0]},
      b: {[-6, -7, -4], [0, 0, 0]},
      c: {[-9, 11, 0], [0, 0, 0]},
      d: {[-3, -4, 6], [0, 0, 0]}
    }, 1000) == 7098
  end

  test "example pt2" do
    assert Twelve.solve_pt2(%{
      a: {[-1, 0, 2], [0, 0, 0]},
      b: {[2, -10, -7], [0, 0, 0]},
      c: {[4, -8, 8], [0, 0, 0]},
      d: {[3, 5, -1], [0, 0, 0]}
    }) == 2772
  end

  test "example pt2 long" do
    state = %{
      a: {[-8, -10, 0], [0, 0, 0]},
      b: {[5, 5, 10], [0, 0, 0]},
      c: {[2, -7, 3], [0, 0, 0]},
      d: {[9, -8, -3], [0, 0, 0]}
    }

    assert Twelve.solve_pt2(state) == 4_686_774_924
  end

  test "pt2" do
    state = %{
      a: {[6, -2, -7], [0, 0, 0]},
      b: {[-6, -7, -4], [0, 0, 0]},
      c: {[-9, 11, 0], [0, 0, 0]},
      d: {[-3, -4, 6], [0, 0, 0]}
    }
    assert Twelve.solve_pt2(state) == 400128139852752
  end
end

# x1 y1 z1 vx1 vy1 vz1
# x2 y2 z2 vx2 vy2 vz2
# x3 y3 z3 vx3 vy3 vz3
# x4 y4 z4 vx4 vy4 vz4

# apply gravity

# x1 = ((x1 - x2) / abs(x1 - x2)) + ((x1 - x3) / abs(x1 - x3)) + ((x1 - x4) / abs(x1 - x4))

# 4 5
