defmodule Three do
  def solution(one, two) do
    one_coords = expand_coords([{0, 0}], String.split(one, ","))
    two_coords = expand_coords([{0 ,0}], String.split(two, ","))

    combined = Enum.reduce(one_coords, %{}, fn {x, y}, acc -> Map.put(acc, {x, y}, true) end)
    overlap = Enum.filter(two_coords, & Map.get(combined, &1, false) and &1 != {0, 0})

    {x, y} =
      Enum.sort_by(overlap, fn {x, y} ->
        abs(x) + abs(y)
      end)
      |> List.first()

    abs(x) + abs(y)
  end

  def solution_2(one, two) do
    one_coords = expand_coords([{0, 0}], String.split(one, ","))
    one_length = length(one_coords)
    one_dist = one_coords |> Enum.with_index() |> Enum.reduce(%{}, fn {coord, index}, acc ->
      Map.put(acc, coord, one_length - index - 1)
    end)

    two_coords = expand_coords([{0 ,0}], String.split(two, ","))
    two_length = length(two_coords)
    two_dist = two_coords |> Enum.with_index() |> Enum.reduce(%{}, fn {{x, y}, index}, acc ->
      Map.put(acc, {x, y}, two_length - index - 1)
    end)

    overlap = Enum.filter(two_coords, & !!Map.get(one_dist, &1) and &1 != {0, 0})

    coord =
      Enum.sort_by(overlap, fn coord ->
        one_distance = Map.get(one_dist, coord)
        two_distance = Map.get(two_dist, coord)
        one_distance + two_distance
      end)
      |> List.first()

    one_distance = Map.get(one_dist, coord)
    two_distance = Map.get(two_dist, coord)
    one_distance + two_distance
  end

  defp expand_coords(coords = [{curr_x, curr_y} | _], ["R" <> instr | rest_instr]) do
    amount = String.to_integer(instr)
    new_coords = for x <- (curr_x+1..curr_x + amount), do: {x, curr_y}
    coords = Enum.reduce(new_coords, coords, fn coord, coords ->
      [coord | coords]
    end)

    expand_coords(coords, rest_instr)
  end

  defp expand_coords(coords = [{curr_x, curr_y} | _], ["L" <> instr | rest_instr]) do
    amount = String.to_integer(instr)
    new_coords = for x <- (curr_x-1..curr_x - amount), do: {x, curr_y}
    coords = Enum.reduce(new_coords, coords, fn coord, coords ->
      [coord | coords]
    end)

    expand_coords(coords, rest_instr)
  end

  defp expand_coords(coords = [{curr_x, curr_y} | _], ["U" <> instr | rest_instr]) do
    amount = String.to_integer(instr)
    new_coords = for y <- (curr_y+1..curr_y + amount), do: {curr_x, y}
    coords = Enum.reduce(new_coords, coords, fn coord, coords ->
      [coord | coords]
    end)

    expand_coords(coords, rest_instr)
  end

  defp expand_coords(coords = [{curr_x, curr_y} | _], ["D" <> instr | rest_instr]) do
    amount = String.to_integer(instr)
    new_coords = for y <- (curr_y-1..curr_y - amount), do: {curr_x, y}
    coords = Enum.reduce(new_coords, coords, fn coord, coords ->
      [coord | coords]
    end)

    expand_coords(coords, rest_instr)
  end

  defp expand_coords(coords, []), do: coords
end
