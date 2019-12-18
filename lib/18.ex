defmodule Eighteen do
  defmodule TryTwo do
    def solve(graph, curr) do
      graph = Enum.map(graph, fn {coord, char} -> {coord, List.first(String.to_charlist(char))} end) |> Enum.into(%{})
      keys = Enum.filter(graph, fn {_, char} -> char in (?a..?z) end)
      key_coords = Enum.map(keys, & elem(&1, 0))
      # {distance_map, path_map} = distance_between_all_keys(graph, [{curr, ?@} | keys])

      # IO.inspect {path_map, keys}, limit: :infinity
      # throw :x

      Agent.start_link(fn -> 100_000 end, name: __MODULE__)
      IO.puts "Starting iteration..."

      {parents, ended} = bfs([{curr, keys, graph}], %{}, 0, MapSet.new([{curr, keys}]))
      fill_parents(parents, [], ended, {curr, keys, graph}) |> elem(0)
      # Enum.map((0..length(keys) - 1), fn i ->
      #   Task.async(fn ->
      #     iterate({graph, distance_map, path_map, i}, curr, ["@"], 0, keys, MapSet.new())
      #   end)
      # end)
      # |> Enum.each(& Task.await(&1, :infinity))
    end

    def fill_parents(_parents, path, target, target), do: {length(path), path}

    def fill_parents(parents, path, curr, target) do
      IO.inspect length(path)
      parent = Map.fetch!(parents, curr)
      fill_parents(parents, [elem(parent, 0) | path], parent, target)
    end

    def djikstra(source = {_, _, graph}, acc) do
      {dist, prev, q} = Enum.reduce(graph, {%{}, %{}, MapSet.new()}, fn {coord, char}, {dist, prev, q} ->
        dist = Map.put(dist, coord, 999_999_999_999_999)
        q = MapSet.put(q, coord)
        {dist, prev, q}
      end)

      dist = Map.put(dist, source, 0)

      {dist, prev} = djikstra_process({dist, prev, q})
    end

    def djikstra_process({dist, prev, q}) do
      if MapSet.size(q) == 0 do
        {dist, prev}
      else
        u_bundle = {u, remain_keys, graph} =
          q
          |> MapSet.to_list()
          |> Enum.sort_by(fn {coord, _, _} ->
            Map.fetch!(dist, coord)
          end)
          |> List.first()

        if remain_keys == [] do
          {dist, prev}
        else
          u_dist = Map.fetch!(dist, u)

          if u_dist > 1_000_000 do
            :fail
          else
            q = MapSet.delete(q, u)

            char = Map.fetch!(graph, u)
            next_remain_keys = if char in ?a..?z do
              IO.inspect "found key #{[char]}, #{length(remain_keys)}"
              List.delete(remain_keys, {curr, char})
            else
              remain_keys
            end

            next_graph = if char in ?a..?z do
              door = char - 32

              Enum.map(graph, fn
                {coord, ^door} -> {coord, ?.}
                # {coord, ^char} -> {coord, ?.}
                ret -> ret
              end) |> Enum.into(%{})
            else
              graph
            end

            neighbors = doored_neighbors(graph, u) |> Enum.map(fn coord -> {coord, next_remain_keys, next_graph} end)

            {dist, prev} =
              neighbors
              |> Enum.reduce({dist, prev}, fn {coord, _, _}, {dist, prev} ->
                alt = u_dist + 1

                if alt < Map.fetch!(dist, coord) do
                  dist = Map.put(dist, coord, alt)
                  prev = Map.put(prev, coord, u)
                  {dist, prev}
                else
                  {dist, prev}
                end
              end)

            djikstra_process({dist, prev, q})
          end
        end
      end
    end

    def bfs(_, [], _parents, cost, remain_keys, _), do: {:fail, cost, remain_keys}

    def bfs([curr_bundle = {curr, remain_keys, graph} | q], parents, cost, discovered) do
      char = Map.fetch!(graph, curr)

      next_remain_keys = if char in ?a..?z do
        IO.inspect "found key #{[char]}, #{length(remain_keys)}"
        List.delete(remain_keys, {curr, char})
      else
        remain_keys
      end

      next_graph = if char in ?a..?z do
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
        {parents, curr_bundle}
      else
        neighbors = doored_neighbors(graph, curr) |> Enum.map(fn coord -> {coord, next_remain_keys, next_graph} end)
        # IO.inspect {curr, Enum.map(neighbors, &elem(&1, 0))}
        clean_neighbors = Enum.reject(neighbors, fn neighbor -> MapSet.member?(discovered, neighbor) end)
        next_discovered = Enum.reduce(clean_neighbors, discovered, & MapSet.put(&2, &1))
        next_parents = Enum.reduce(clean_neighbors, parents, & Map.put(&2, &1, curr_bundle))
        next_q = q ++ clean_neighbors #Enum.map(clean_neighbors, & elem(&1, 0))

        bfs(next_q, next_parents, cost + 1, next_discovered)
      end
    end

    def iterate({graph, distm, pathm, start_at}, curr, path = [from | _], path_cost, remain_keys, seen_paths) do
      # IO.inspect path
      if remain_keys == [] do
        # IO.inspect {path_cost, path}
        if path_cost <= Agent.get(__MODULE__, & &1) do
          Agent.update(__MODULE__, fn old ->
            min(path_cost, old)
          end)

          IO.inspect {path_cost, path}
        end

        seen_paths
      else
        space =
          (if length(path) == 1, do: [Enum.at(remain_keys, start_at)], else: remain_keys)
          |> Enum.flat_map(fn {coord, key} ->
            to = to_string([key])
            valid_paths =
              Map.fetch!(pathm, {from, to})
              |> Enum.reject(fn {path_length, gates, keys} ->
                # IO.inspect {from, to, to_string(path), Enum.map(remain_keys, & elem(&1, 1)) |> to_string(), keys}
                Enum.any?(gates, fn gate_char ->
                  Enum.find(remain_keys, fn {_, check_char} ->
                    gate_char == check_char - 32
                  end)
                end) || Enum.any?(keys, fn key_char ->
                  Enum.find(remain_keys, fn {_, check_char} ->
                    key_char == check_char
                  end)
                end)
              end)

            # dist = Enum.map(valid_paths, & elem(&1, 0)) |> Enum.sort() |> List.first()

            # IO.inspect {from, to, valid_paths}

            Enum.map(valid_paths, fn {dist, _g, _k} ->
              {dist, coord, key, to_string([key])}
            end)
          end)
          |> Enum.reject(& elem(&1, 0) == nil)
          |> Enum.sort_by(& elem(&1, 0))

        # if length(space) > 6, do: IO.inspect {"Space is #{length(space)}", path, remain_keys}

        space
        # |> Enum.take(max(ceil(length(remain_keys) / 2), 2))
        |> Enum.reduce(seen_paths, fn {dist, next_curr, char, str}, seen_paths ->
          graph = case Enum.find(graph, fn {_, door?} -> door? == char - 32 end) do
            nil -> graph
            {ret, _} -> Map.put(graph, ret, ".")
          end

          next_path = [str | path]
          # IO.inspect to_string(next_path)
          next_cost = path_cost + dist
          if MapSet.member?(seen_paths, {next_path, next_cost}) do
            # IO.puts "I've seen it already: #{next_path} #{next_cost}"
            seen_paths
          else
            seen_paths = MapSet.put(seen_paths, {next_path, next_cost})
            iterate({graph, distm, pathm, start_at}, next_curr, next_path, next_cost, List.delete(remain_keys, {next_curr, char}), seen_paths)
          end
        end)
      end
      # IO.inspect {path_cost, length(path), path}
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

    def doored_neighbors(graph, {c, r}) do
      [{c - 1, r}, {c + 1, r}, {c, r - 1}, {c, r + 1}]
      |> Enum.filter(fn coord ->
        char = Map.get(graph, coord, ?#)
        char != ?# and char not in (?A..?Z)
      end)
    end
  end

  def solve(input) do
    graph = parse_input(input)
    {curr, "@"} = Enum.find(graph, fn {_coords, val} -> val == "@" end)
    graph = Map.put(graph, curr, ".")

    TryTwo.solve(graph, curr)
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
