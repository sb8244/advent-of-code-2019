defmodule FourTest do
  use ExUnit.Case

  test "match" do
    assert Four.is_match?(111111)
    refute Four.is_match?(223450)
    refute Four.is_match?(123789)

    assert Four.is_match?(112233, false)
    refute Four.is_match?(123444, false)
    refute Four.is_match?(222122, false)
    assert Four.is_match?(111122, false)
  end

  test "pt1" do
    assert Four.solve({137683, 596253}) == 1864
  end

  test "pt2" do
    assert Four.solve({137683, 596253}, false) == 1258
  end
end
