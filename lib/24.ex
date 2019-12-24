defmodule TwentyFour do
  def parse(input) do
    String.split(input, "\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, r}, acc ->
      String.split(line, "", trim: true)
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {s, c}, acc ->
        Map.put(acc, {r, c}, s)
      end)
    end)
  end

  def next(state) do
    Enum.reduce(state, %{}, fn {{r, c}, s}, next ->
      count = neighbor_count(state, {r, c})

      next_s =
        if s == "#" do
          if count == 1 do
            "#"
          else
            "."
          end
        else
          if count == 1 || count == 2 do
            "#"
          else
            "."
          end
        end

      Map.put(next, {r, c}, next_s)
    end)
  end

  def iter_until_repeat(state) do
    iter_until_repeat(state, MapSet.new())
  end

  def iter_until_repeat(state, seen) do
    if MapSet.member?(seen, state) do
      state
    else
      iter_until_repeat(next(state), MapSet.put(seen, state))
    end
  end

  def sum_bio(state) do
    Enum.reduce(state, {0, 1}, fn {_, s}, {sum, incr} ->
      sum =
        if s == "#" do
          sum + incr
        else
          sum
        end

      {sum, incr * 2}
    end)
    |> elem(0)
  end

  defp neighbor_count(state, {r, c}) do
    [{r-1, c}, {r+1, c}, {r, c-1}, {r, c+1}]
    |> Enum.map(fn coor ->
      Map.get(state, coor)
    end)
    |> Enum.reject(& is_nil/1)
    |> Enum.filter(fn s -> s == "#" end)
    |> length()
  end
end
