defmodule TwentyTest do
  use ExUnit.Case

  test "example1" do
    input = File.read!("20_ex1.in")
    assert Twenty.solve(input) == 23
  end

  test "example2" do
    input = File.read!("20_ex2.in")
    assert Twenty.solve(input) == 58
  end

  test "pt1" do
    input = File.read!("20.in")
    assert Twenty.solve(input) == 580
  end

  test "pt2 ex1" do
    input = File.read!("20_ex1.in")
    assert Twenty.solve_2(input) == 26
  end

  test "pt2 ex3" do
    input = File.read!("20_ex3.in")
    assert Twenty.solve_2(input) == 396
  end

  test "pt2" do
    input = File.read!("20.in")
    assert Twenty.solve_2(input) == 6362
  end
end
