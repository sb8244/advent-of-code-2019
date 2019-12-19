defmodule Eighteen do
  defmodule TryTwo do
    def solve(graph, curr) do
      graph = Enum.map(graph, fn {coord, char} -> {coord, List.first(String.to_charlist(char))} end) |> Enum.into(%{})
      keys = Enum.filter(graph, fn {_, char} -> char in (?a..?z) end)

      start = {curr, keys, graph, [], [curr]}
      q = :queue.new()
      q = :queue.in(start, q)
      bfs(q, MapSet.new([start]))
    end

    def solve_2(graph, [a, b, c, d]) do
      graph = Enum.map(graph, fn {coord, char} -> {coord, List.first(String.to_charlist(char))} end) |> Enum.into(%{})
      keys = Enum.filter(graph, fn {_, char} -> char in (?a..?z) end)

      # IO.puts "Starting iteration... #{inspect currs}"

      # KEep track of all of the locations and use that to project the next neighbor
      visited1 = {a, keys, graph, [b, c, d], [a]}
      visited2 = {b, keys, graph, [a, c, d], [b]}
      visited3 = {c, keys, graph, [a, b, d], [c]}
      visited4 = {d, keys, graph, [a, b, c], [d]}
      q = :queue.new()
      q = :queue.in(visited1, q)
      q = :queue.in(visited2, q)
      q = :queue.in(visited3, q)
      q = :queue.in(visited4, q)

      bfs(q, MapSet.new())
    end


    def bfs(q, discovered) do
      case :queue.out(q) do
        {:empty, _} -> :fail
        {{:value, {curr, remain_keys, graph, others, cost}}, q} ->
          char = Map.fetch!(graph, curr)

          next_remain_keys =
            if char in ?a..?z do
              # IO.inspect "found key #{[char]}, #{length(remain_keys)}, #{length(cost)}"
              List.delete(remain_keys, {curr, char})
            else
              remain_keys
            end

          if length(next_remain_keys) == 0 do
            # IO.inspect "DONE"
            cost
          else
            neighbors =
              doored_neighbors(graph, curr, others, next_remain_keys)
              |> Enum.map(fn {coord, next_others} -> {coord, next_remain_keys, graph, next_others, [coord | cost]} end)

            clean_neighbors = Enum.reject(neighbors, fn {a,b,_c,_d,_} -> MapSet.member?(discovered, {a,b}) end)
            next_discovered = Enum.reduce(clean_neighbors, discovered, fn {a,b,_c,_d, _}, acc -> MapSet.put(acc, {a,b}) end)
            next_q = Enum.reduce(clean_neighbors, q, & :queue.in(&1, &2))

            bfs(next_q, next_discovered)
          end
      end
    end

    def doored_neighbors(graph, a, [b, c, d], remain_keys) do
      (doored_neighbors(graph, a, [], remain_keys) |> Enum.map(fn {coords, _} -> {coords, [b, c, d]} end)) ++
      (doored_neighbors(graph, b, [], remain_keys) |> Enum.map(fn {coords, _} -> {coords, [a, c, d]} end)) ++
      (doored_neighbors(graph, c, [], remain_keys) |> Enum.map(fn {coords, _} -> {coords, [a, b, d]} end)) ++
      (doored_neighbors(graph, d, [], remain_keys) |> Enum.map(fn {coords, _} -> {coords, [a, b, c]} end))
    end

    def doored_neighbors(graph, {c, r}, [], remain_keys) do
      remain_keys = Enum.map(remain_keys, &elem(&1, 1))

      [{c - 1, r}, {c + 1, r}, {c, r - 1}, {c, r + 1}]
      |> Enum.filter(fn coord ->
        char = Map.get(graph, coord, ?#)
        match = char == ?. or char == ?@ or char in (?a..?z) or (char in (?A..?Z) and char+32 not in remain_keys)
        # if char in (?A..?Z), do: IO.inspect {coord, to_string([char]), match, remain_keys}
        match
      end)
      |> Enum.map(fn coord -> {coord, []} end)
    end
  end

  def solve(input) do
    graph = parse_input(input)
    {curr, "@"} = Enum.find(graph, fn {_coords, val} -> val == "@" end)
    graph = Map.put(graph, curr, ".")

    TryTwo.solve(graph, curr)
  end

  def solve_2(input) do
    graph = parse_input(input)
    entries = Enum.filter(graph, fn {_coords, val} -> val == "@" end) |> Enum.map(& elem(&1, 0))
    graph = Enum.reduce(entries, graph, fn curr, graph -> Map.put(graph, curr, ".") end) |> Enum.into(%{})

    TryTwo.solve_2(graph, entries)
  end

  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, r}, acc ->
      String.split(line, "", trim: true)
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {char, c}, acc ->
        Map.put(acc, {c, r}, char)
      end)
    end)
  end
end
