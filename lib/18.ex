defmodule Eighteen do
  defmodule TryTwo do
    def solve(graph, curr) do
      graph = Enum.map(graph, fn {coord, char} -> {coord, List.first(String.to_charlist(char))} end) |> Enum.into(%{})
      keys = Enum.filter(graph, fn {_, char} -> char in (?a..?z) end)

      start = {curr, keys, graph, [], 0}
      bfs([start], %{}, MapSet.new([start]))
      # fill_parents(parents, [], ended, [start]) |> elem(0)
    end

    def solve_2(graph, currs = [a, b, c, d]) do
      graph = Enum.map(graph, fn {coord, char} -> {coord, List.first(String.to_charlist(char))} end) |> Enum.into(%{})
      keys = Enum.filter(graph, fn {_, char} -> char in (?a..?z) end)

      IO.puts "Starting iteration... #{inspect currs}"

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

    def bfs(_, [], _parents, remain_keys, _), do: {:fail, remain_keys}

    def bfs([curr_bundle = {curr, remain_keys, graph, others, cost} | q], parents, discovered) do
      IO.inspect curr
      char = Map.fetch!(graph, curr)

      next_remain_keys =
        if char in ?a..?z do
          IO.inspect "found key #{[char]}, #{length(remain_keys)}, #{cost}"
          List.delete(remain_keys, {curr, char})
        else
          remain_keys
        end

      next_graph =
        if char in ?a..?z do
          door = char - 32

          Enum.map(graph, fn
            {coord, ^door} -> {coord, ?.}
            # {coord, ^char} -> {coord, ?.}
            ret -> ret
          end) |> Enum.into(%{})
        else
          graph
        end

      if length(next_remain_keys) == 0 do
        IO.inspect "DONE"
        # {parents, {curr, remain_keys, graph}}
        cost
      else
        neighbors =
          doored_neighbors(graph, curr, others)
          |> Enum.map(fn {coord, next_others} -> {coord, next_remain_keys, next_graph, next_others, cost + 1} end)
          |> Enum.reject(fn {_, remaining, _, _, cost} ->
            length(remaining) > 5 and cost > 50
          end)

        clean_neighbors = Enum.reject(neighbors, fn {a,b,c,d, _} -> MapSet.member?(discovered, {a,b,c}) end)
        next_discovered = Enum.reduce(clean_neighbors, discovered, fn {a,b,c,d, _}, acc -> MapSet.put(acc, {a,b,c}) end)
        # next_parents = Enum.reduce(clean_neighbors, parents, fn {a,b,c,d,_}, acc -> Map.put(acc, {a,b,c}, {curr, remain_keys, graph}) end)
        next_q = q ++ clean_neighbors #Enum.map(clean_neighbors, & elem(&1, 0))

        bfs(next_q, parents, next_discovered)
      end
    end

    def distance_between_all_keys(graph, keys) do
      Combination.combine(keys, 2)
      |> Enum.map(fn [{source_coord, source}, {target_coord, target}] ->
        Task.async(fn ->
          # dist = shortest_path({graph, target_coord}, source_coord, MapSet.new(), 0, &neighbors/2)
          all = all_paths({graph, source_coord, target_coord}, source_coord, MapSet.new(), {0, [], []}, &neighbors/2)
          {dist, _, _} = Enum.sort_by(all, & elem(&1, 0)) |> List.first()

          source = to_string([source])
          target = to_string([target])
          {
            %{{source, target} => dist, {target, source} => dist},
            %{{source, target} => all, {target, source} => all}
          }
        end)
      end)
      |> Enum.map(& Task.await(&1, :infinity))
      |> Enum.reduce({%{}, %{}}, fn {dist, all}, {acc_dist, acc_all} ->
        {
          Map.merge(acc_dist, dist),
          Map.merge(acc_all, all)
        }
      end)
    end

    def shortest_path({_graph, target}, target, _, count, _), do: count
    def shortest_path({graph, target}, curr, visited, count, neighbor_fn) do
      visited = MapSet.put(visited, curr)
      neighbors = neighbor_fn.(graph, curr) |> Enum.reject(&MapSet.member?(visited, &1))

      vals =
        neighbors
        |> Enum.map(fn next ->
          shortest_path({graph, target}, next, visited, count + 1, neighbor_fn)
        end)
        |> Enum.reject(& is_nil(&1))

      # if length(vals) > 1, do: IO.inspect(vals, as_charlists: false)

      List.first(vals)
    end

    def all_paths({_graph, source, target}, target, _, counts, _), do: counts
    def all_paths({graph, source, target}, curr, visited, {count, doors, keys}, neighbor_fn) do
      source_char = Map.fetch!(graph, source)
      target_char = Map.fetch!(graph, target)
      visited = MapSet.put(visited, curr)
      neighbors = neighbor_fn.(graph, curr) |> Enum.reject(&MapSet.member?(visited, &1))

      vals =
        neighbors
        |> Enum.map(fn next ->
          next_char = Map.fetch!(graph, next)
          doors = if next_char in (?A..?Z), do: [next_char | doors], else: doors
          keys = if next_char not in [source_char, target_char] and next_char in (?a..?z), do: [next_char | keys], else: keys

          all_paths({graph, source, target}, next, visited, {count + 1, doors, keys}, neighbor_fn)
        end)
        |> List.flatten()
        |> Enum.reject(fn {count, _, _} -> count == nil end)
        |> Enum.sort_by(fn {c, _, _} -> c end)
        |> Enum.uniq_by(fn {_, a, b} -> {a, b} end)

      if length(vals) == 0, do: [{nil, nil, nil}], else: vals
    end

    def neighbors(graph, {c, r}) do
      [{c - 1, r}, {c + 1, r}, {c, r - 1}, {c, r + 1}]
      |> Enum.filter(& Map.get(graph, &1, ?#) != ?#)
    end

    def doored_neighbors(graph, a, [b, c, d]) do
      (doored_neighbors(graph, a, []) |> Enum.map(fn {coords, _} -> {coords, [b, c, d]} end)) ++
      (doored_neighbors(graph, b, []) |> Enum.map(fn {coords, _} -> {coords, [a, c, d]} end)) ++
      (doored_neighbors(graph, c, []) |> Enum.map(fn {coords, _} -> {coords, [a, b, d]} end)) ++
      (doored_neighbors(graph, d, []) |> Enum.map(fn {coords, _} -> {coords, [a, b, c]} end))
    end

    def doored_neighbors(graph, {c, r}, []) do
      [{c - 1, r}, {c + 1, r}, {c, r - 1}, {c, r + 1}]
      |> Enum.filter(fn coord ->
        char = Map.get(graph, coord, ?#)
        char != ?# and char not in (?A..?Z)
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

  def solve(input) do
    graph = parse_input(input)
    {curr, "@"} = Enum.find(graph, fn {_coords, val} -> val == "@" end)
    graph = Map.put(graph, curr, ".")

    multi_result = djikstra(graph, curr, [])

    IO.inspect {"num results", length(multi_result)}

    Enum.map(multi_result, fn bundle ->
      backtrack(bundle) |> IO.inspect()
    end)
    |> Enum.map(fn list ->
      length(list) - 1
    end)
    |> Enum.sum()
  end

  def backtrack({dist, prev, from_coord, source_coord}) do
    s = []
    u = from_coord

    if Map.has_key?(prev, u) or u == from_coord do
      backtrack_sub(s, prev, u, source_coord)
    end
  end

  def backtrack_sub(s, _prev, coord, coord), do: [coord | s]
  def backtrack_sub(s, _prev, nil, _source), do: s
  def backtrack_sub(s, prev, u, source) do
    s = [u | s]
    u = Map.get(prev, u)
    backtrack_sub(s, prev, u, source)
  end

  def djikstra(graph, source, acc) do
    {dist, prev, q} = Enum.reduce(graph, {%{}, %{}, MapSet.new()}, fn {coord, char}, {dist, prev, q} ->
      dist = Map.put(dist, coord, 999_999_999_999_999)
      q = MapSet.put(q, coord)
      {dist, prev, q}
    end)

    dist = Map.put(dist, source, 0)

    {graph, dist, prev, from_coord} = djikstra_process(graph, {dist, prev, q}, nil)
    acc = [{dist, prev, from_coord, source} | acc]
    # IO.inspect {dist, prev, from_coord, no_keys_or_doors?(graph)}
    IO.inspect {source, from_coord}

    if no_keys_or_doors?(graph) do
      acc
    else
      djikstra(graph, from_coord, acc)
    end
  end

  def djikstra_process(graph, {dist, prev, q}, from_coord) do
    if MapSet.size(q) == 0 or no_keys_or_doors?(graph) do
      {graph, dist, prev, from_coord}
    else
      u =
        q
        |> MapSet.to_list()
        |> Enum.sort_by(fn coord ->
          Map.fetch!(dist, coord)
        end)
        |> List.first()

      u_dist = Map.fetch!(dist, u)

      if u_dist > 1_000_000 do
        {graph, dist, prev, from_coord}
      else
        IO.inspect {"process", u, u_dist, Map.fetch!(graph, u)}
        q = MapSet.delete(q, u)

        {graph, change_coord} = modify_pickup(graph, u)
        next_from_cord = change_coord || from_coord

        {dist, prev} =
          neighbors(graph, q, u)
          |> Enum.reduce({dist, prev}, fn coord, {dist, prev} ->
            alt = u_dist + segment_size(graph, u, coord)

            if alt < Map.fetch!(dist, coord) do
              dist = Map.put(dist, coord, alt)
              prev = Map.put(prev, coord, u)
              {dist, prev}
            else
              {dist, prev}
            end
          end)

        djikstra_process(graph, {dist, prev, q}, next_from_cord)
      end
    end
  end

  def segment_size(graph, _u, coord) do
    [to] = Map.fetch!(graph, coord) |> String.to_charlist()

    if to in (?A..?Z) or to == ?# do
      900_000_000_000_000_000_000
    else
      1
    end
  end

  def no_keys_or_doors?(graph) do
    graph
    |> Map.values()
    |> Enum.all?(fn str ->
      str == "." or str == "#"
    end)
  end

  def modify_pickup(graph, coord) do
    val = Map.fetch!(graph, coord)

    if val not in [".", "#"] do
      upper = String.upcase(val)

      if upper == val, do: throw "A key pickup should have happened, but it's a door pickup #{val} == #{upper}"

      # IO.inspect {"key pickup", val, upper}

      graph = Map.put(graph, coord, ".")

      graph = case Enum.find(graph, fn {_, char} -> char == upper end) do
        nil -> graph
        {ret, _} -> Map.put(graph, ret, ".")
      end

      {graph, coord}
    else
      {graph, nil}
    end
  end

  def neighbors(graph, q, {c, r}) do
    [{c - 1, r}, {c + 1, r}, {c, r - 1}, {c, r + 1}]
    |> Enum.filter(& Map.has_key?(graph, &1))
  end

  def unprocessed_neighbors(graph, q, {c, r}) do
    [{c - 1, r}, {c + 1, r}, {c, r - 1}, {c, r + 1}]
    |> Enum.filter(&
      Map.has_key?(graph, &1) and MapSet.member?(q, &1)
    )
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
