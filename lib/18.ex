defmodule Eighteen do
  defmodule TryTwo do
    def solve(graph, curr) do
      graph = Enum.map(graph, fn {coord, char} -> {coord, List.first(String.to_charlist(char))} end) |> Enum.into(%{})
      keys = Enum.filter(graph, fn {_, char} -> char in (?a..?z) end)

      start = {curr, keys, graph, [], 0}
      bfs([start], %{}, MapSet.new([start]))
      # fill_parents(parents, [], ended, [start]) |> elem(0)
    end

    def solve_2(graph, [a, b, c, d]) do
      graph = Enum.map(graph, fn {coord, char} -> {coord, List.first(String.to_charlist(char))} end) |> Enum.into(%{})
      keys = Enum.filter(graph, fn {_, char} -> char in (?a..?z) end)

      # IO.puts "Starting iteration... #{inspect currs}"

      # KEep track of all of the locations and use that to project the next neighbor
      visited1 = {a, keys, graph, [b, c, d], 0}
      visited2 = {b, keys, graph, [a, c, d], 0}
      visited3 = {c, keys, graph, [a, b, d], 0}
      visited4 = {d, keys, graph, [a, b, c], 0}
      q = [visited1, visited2, visited3, visited4]

      bfs(q, %{}, MapSet.new(q))
    end

    def fill_parents(parents, path, curr, targets) do
      if curr in targets do
        {length(path), path}
      else
        IO.inspect {length(path), curr}
        parent = Map.fetch!(parents, curr)
        fill_parents(parents, [elem(parent, 0) | path], parent, targets)
      end
    end

    def bfs([], _parents, _discovered), do: {:fail}

    def bfs([{curr, remain_keys, graph, others, cost} | q], parents, discovered) do
      char = Map.fetch!(graph, curr)
      # IO.inspect {curr, to_string([char])}

      next_remain_keys =
        if char in ?a..?z do
          # IO.inspect "found key #{[char]}, #{length(remain_keys)}, #{cost}"
          List.delete(remain_keys, {curr, char})
        else
          remain_keys
        end

      # next_graph =
      #   if char in ?a..?z do
      #     door = char - 32

      #     Enum.map(graph, fn
      #       {coord, ^door} -> {coord, ?.}
      #       # {coord, ^char} -> {coord, ?.}
      #       ret -> ret
      #     end) |> Enum.into(%{})
      #   else
      #     graph
      #   end

      if length(next_remain_keys) == 0 do
        # IO.inspect "DONE"
        # {parents, {curr, remain_keys, graph}}
        cost
      else
        neighbors =
          doored_neighbors(graph, curr, others, next_remain_keys)
          |> Enum.map(fn {coord, next_others} -> {coord, next_remain_keys, graph, next_others, cost + 1} end)

        clean_neighbors = Enum.reject(neighbors, fn {a,b,_c,_d,_} -> MapSet.member?(discovered, {a,b}) end)
        next_discovered = Enum.reduce(clean_neighbors, discovered, fn {a,b,_c,_d, _}, acc -> MapSet.put(acc, {a,b}) end)
        # next_parents = Enum.reduce(clean_neighbors, parents, fn {a,b,c,d,_}, acc -> Map.put(acc, {a,b,c}, {curr, remain_keys, graph}) end)
        next_q = q ++ clean_neighbors #Enum.map(clean_neighbors, & elem(&1, 0))

        bfs(next_q, parents, next_discovered)
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
