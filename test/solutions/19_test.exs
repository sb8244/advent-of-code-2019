defmodule NineteenTest do
  use ExUnit.Case

  @program "109,424,203,1,21102,11,1,0,1106,0,282,21102,18,1,0,1106,0,259,1201,1,0,221,203,1,21102,31,1,0,1106,0,282,21101,38,0,0,1106,0,259,21002,23,1,2,22102,1,1,3,21101,1,0,1,21102,57,1,0,1105,1,303,2102,1,1,222,20101,0,221,3,20101,0,221,2,21102,259,1,1,21101,80,0,0,1106,0,225,21101,0,44,2,21102,91,1,0,1105,1,303,1201,1,0,223,20101,0,222,4,21101,0,259,3,21102,225,1,2,21101,225,0,1,21102,118,1,0,1105,1,225,21002,222,1,3,21101,100,0,2,21101,133,0,0,1105,1,303,21202,1,-1,1,22001,223,1,1,21101,148,0,0,1106,0,259,2102,1,1,223,20102,1,221,4,21002,222,1,3,21102,1,12,2,1001,132,-2,224,1002,224,2,224,1001,224,3,224,1002,132,-1,132,1,224,132,224,21001,224,1,1,21102,1,195,0,106,0,108,20207,1,223,2,21002,23,1,1,21102,-1,1,3,21101,0,214,0,1105,1,303,22101,1,1,1,204,1,99,0,0,0,0,109,5,2102,1,-4,249,21201,-3,0,1,22101,0,-2,2,22101,0,-1,3,21101,0,250,0,1105,1,225,22102,1,1,-4,109,-5,2106,0,0,109,3,22107,0,-2,-1,21202,-1,2,-1,21201,-1,-1,-1,22202,-1,-2,-2,109,-3,2106,0,0,109,3,21207,-2,0,-1,1206,-1,294,104,0,99,21202,-2,1,-2,109,-3,2105,1,0,109,5,22207,-3,-4,-1,1206,-1,346,22201,-4,-3,-4,21202,-3,-1,-1,22201,-4,-1,2,21202,2,-1,-1,22201,-4,-1,1,22102,1,-2,3,21101,0,343,0,1105,1,303,1105,1,415,22207,-2,-3,-1,1206,-1,387,22201,-3,-2,-3,21202,-2,-1,-1,22201,-3,-1,3,21202,3,-1,-1,22201,-3,-1,2,21201,-4,0,1,21101,0,384,0,1106,0,303,1106,0,415,21202,-4,-1,-4,22201,-4,-3,-4,22202,-3,-2,-2,22202,-2,-4,-4,22202,-3,-2,-3,21202,-4,-1,-2,22201,-3,-2,1,22102,1,1,-4,109,-5,2106,0,0"

  test "pt1" do
    coords = for c <- (0..49), r <- (0..49), do: {c, r}

    assert Enum.map(coords, fn {c,r} ->
      Process.put(:input, [c, r])
      Process.put(:test_input, fn ->
        [curr | next] = Process.get(:input)
        Process.put(:input, next)
        curr
      end)

      Nineteen.computer(@program)
      {{c,r}, Process.get(:curr_output)}
    end)
    |> Enum.filter(fn {_coords, [output]} ->
      output == "1"
    end)
    |> length() == 147
  end

  @max 10000

  def render(map) do
    IO.write("\n")
    for r <- (0..@max), c <- (0..@max) do
      char = if Map.get(map, {c, r}, false) == true, do: "#", else: "."
      IO.write(char)
      if c == @max, do: IO.write("\n")
    end
  end

  test "pt2" do
    {{x, y}, true} = pt2(%{}, {0, 0}, @max, 1)
    assert x * 10_000 + y == 13280865
  end

  def first_run_100(map) do
    Enum.filter(map, fn {_coords, hit} -> hit end)
    |> Enum.find(fn {{c, r}, true} ->
      Map.get(map, {c+99, r}, false) && Map.get(map, {c, r+99}, false)
    end)
  end

  def pt2(acc, {_c, max_r}, max_r, _last_row_max_c), do: acc
  def pt2(acc, {c, r}, max_r, last_row_max_c) do
    # IO.inspect {c, r}
    # IO.inspect {{c, r}, Map.get(acc, {c-2, r}), Map.get(acc, {c-1, r}), c > last_row_max_c * 2}
    if (Map.get(acc, {c-2, r}) == true and Map.get(acc, {c-1, r}) == false) or c > last_row_max_c * 2 do
      acc = Map.put(acc, {c, r}, false)
      first_c_in_row = Enum.find((0..c), fn c -> Map.get(acc, {c, r}) end) || 0

      if res = first_run_100(acc) do
        res
      else
        pt2(acc, {first_c_in_row, r + 1}, max_r, c)
      end
    else
      Process.put(:input, [c, r])
      Process.put(:test_input, fn ->
        [curr | next] = Process.get(:input)
        Process.put(:input, next)
        curr
      end)

      Nineteen.computer(@program)

      acc = Map.put(acc, {c,r}, Process.get(:curr_output) == ["1"])
      pt2(acc, {c+1, r}, max_r, last_row_max_c)
    end
  end
end
