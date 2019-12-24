defmodule TwentyFourRecursive do
  def parse(input) do
    # make the board bigger than the 200 ticks needed
    full =
      for r <- 0..4, c <- 0..4, d <- -150..150 do
        {{{r, c}, d}, "."}
      end
      |> Enum.into(%{})

    TwentyFour.parse(input)
    |> Enum.map(fn {coord, s} ->
      {{coord, 0}, s}
    end)
    |> Enum.into(full)
  end

  def next(state) do
    Enum.reduce(state, %{}, fn
      {p = {{2, 2}, _}, _}, next ->
        Map.put(next, p, "?")

      {p, s}, next ->
        count = neighbor_count(state, p)

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

        Map.put(next, p, next_s)
    end)
  end

  defp neighbor_count(state, at) do
    # if at == {{0, 1}, -2} do
    #   IO.inspect(neighbors(state, at) ++ reg_neighbors(state, at))
    # end

    (neighbors(state, at) ++ reg_neighbors(state, at))
    |> Enum.map(fn coor ->
      Map.get(state, coor, ".")
    end)
    |> Enum.filter(fn s -> s == "#" end)
    |> length()
  end

  # A
  defp neighbors(state, {{0, 0}, d}), do: [{{1, 2}, d + 1}, {{2, 1}, d + 1}]
  # B
  defp neighbors(state, {{0, 1}, d}), do: [{{1, 2}, d + 1}]
  # C
  defp neighbors(state, {{0, 2}, d}), do: [{{1, 2}, d + 1}]
  # D
  defp neighbors(state, {{0, 3}, d}), do: [{{1, 2}, d + 1}]
  # E
  defp neighbors(state, {{0, 4}, d}), do: [{{1, 2}, d + 1}, {{2, 3}, d + 1}]

  # F
  defp neighbors(state, {{1, 0}, d}), do: [{{2, 1}, d + 1}]
  # G
  defp neighbors(state, {{1, 1}, d}), do: []
  # H
  defp neighbors(state, {{1, 2}, d}),
    do: [{{0, 0}, d - 1}, {{0, 1}, d - 1}, {{0, 2}, d - 1}, {{0, 3}, d - 1}, {{0, 4}, d - 1}]

  # I
  defp neighbors(state, {{1, 3}, d}), do: []
  # J
  defp neighbors(state, {{1, 4}, d}), do: [{{2, 3}, d + 1}]

  # K
  defp neighbors(state, {{2, 0}, d}), do: [{{2, 1}, d + 1}]
  # L
  defp neighbors(state, {{2, 1}, d}),
    do: [{{0, 0}, d - 1}, {{1, 0}, d - 1}, {{2, 0}, d - 1}, {{3, 0}, d - 1}, {{4, 0}, d - 1}]

  # ?
  defp neighbors(state, {{2, 2}, d}), do: []
  # N
  defp neighbors(state, {{2, 3}, d}),
    do: [{{0, 4}, d - 1}, {{1, 4}, d - 1}, {{2, 4}, d - 1}, {{3, 4}, d - 1}, {{4, 4}, d - 1}]

  # O
  defp neighbors(state, {{2, 4}, d}), do: [{{2, 3}, d + 1}]

  # P
  defp neighbors(state, {{3, 0}, d}), do: [{{2, 1}, d + 1}]
  # Q
  defp neighbors(state, {{3, 1}, d}), do: []
  # R
  defp neighbors(state, {{3, 2}, d}),
    do: [{{4, 0}, d - 1}, {{4, 1}, d - 1}, {{4, 2}, d - 1}, {{4, 3}, d - 1}, {{4, 4}, d - 1}]

  # S
  defp neighbors(state, {{3, 3}, d}), do: []
  # T
  defp neighbors(state, {{3, 4}, d}), do: [{{2, 3}, d + 1}]

  # U
  defp neighbors(state, {{4, 0}, d}), do: [{{2, 1}, d + 1}, {{3, 2}, d + 1}]
  # V
  defp neighbors(state, {{4, 1}, d}), do: [{{3, 2}, d + 1}]
  # W
  defp neighbors(state, {{4, 2}, d}), do: [{{3, 2}, d + 1}]
  # X
  defp neighbors(state, {{4, 3}, d}), do: [{{3, 2}, d + 1}]
  # Y
  defp neighbors(state, {{4, 4}, d}), do: [{{2, 3}, d + 1}, {{3, 2}, d + 1}]

  defp reg_neighbors(state, {{r, c}, d}) do
    [{{r - 1, c}, d}, {{r + 1, c}, d}, {{r, c - 1}, d}, {{r, c + 1}, d}]
    |> Enum.map(fn coor ->
      {coor, Map.get(state, coor)}
    end)
    |> Enum.reject(fn {_, s} -> is_nil(s) end)
    |> Enum.map(&elem(&1, 0))
  end
end

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
    [{r - 1, c}, {r + 1, c}, {r, c - 1}, {r, c + 1}]
    |> Enum.map(fn coor ->
      Map.get(state, coor)
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.filter(fn s -> s == "#" end)
    |> length()
  end
end
