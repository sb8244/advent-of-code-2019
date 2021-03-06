defmodule TwoTest do
  use ExUnit.Case

  test "example" do
    assert Two.solve("1,9,10,3,2,3,11,0,99,30,40,50") == 3500
    assert Two.solve("1,0,0,0,99") == 2
  end

  @input "1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,9,1,19,1,19,5,23,1,9,23,27,2,27,6,31,1,5,31,35,2,9,35,39,2,6,39,43,2,43,13,47,2,13,47,51,1,10,51,55,1,9,55,59,1,6,59,63,2,63,9,67,1,67,6,71,1,71,13,75,1,6,75,79,1,9,79,83,2,9,83,87,1,87,6,91,1,91,13,95,2,6,95,99,1,10,99,103,2,103,9,107,1,6,107,111,1,10,111,115,2,6,115,119,1,5,119,123,1,123,13,127,1,127,5,131,1,6,131,135,2,135,13,139,1,139,2,143,1,143,10,0,99,2,0,14,0"

  test "p1" do
    assert Two.solve(@input, {12, 2}) == 6568671
  end

  # I originally did not use `Enum.find` and `for` comprehensions here, but I wanted to speed it
  # up by short circuitng when the solution was found.
  test "p2" do
    iterable = for noun <- (0..99), verb <- (0..99), into: [], do: {noun, verb}

    Enum.find(iterable, fn {noun, verb} ->
      if Two.solve(@input, {noun, verb}) == 19690720 do
        # IO.inspect 100 * noun + verb
        assert 100 * noun + verb == 3951
      end
    end)
  end
end
