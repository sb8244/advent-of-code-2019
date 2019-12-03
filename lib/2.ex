defmodule Two do
  def solve(list, replace = {noun, verb} \\ {nil, nil}) do
    nums = String.split(list, ",") |> Enum.map(&String.to_integer/1)

    positions = nums |> Enum.with_index() |> Enum.reduce(%{}, fn {num, p}, acc ->
      Map.put(acc, p, num)
    end)

    positions = if replace != {nil, nil} do
      Map.merge(positions, %{1 => noun, 2 => verb})
    else
      positions
    end

    process(nums, positions)
  end

  def process([1, p1, p2, r | rest], positions) do
    p1_v = Map.get(positions, p1, 0)
    p2_v = Map.get(positions, p2, 0)
    result = Map.put(positions, r, p1_v + p2_v)

    process(rest, result)
  end

  def process([2, p1, p2, r | rest], positions) do
    p1_v = Map.get(positions, p1, 0)
    p2_v = Map.get(positions, p2, 0)
    result = Map.put(positions, r, p1_v * p2_v)

    process(rest, result)
  end

  def process([99 | _], positions) do
    Map.get(positions, 0)
  end
end
