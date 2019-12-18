defmodule Eighteen do
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

    {graph, dist, prev, from_coord} = djikstra_process([{0, graph}], {dist, prev, q}, nil)
    acc = [{dist, prev, from_coord, source} | acc]
    # IO.inspect {dist, prev, from_coord, no_keys_or_doors?(graph)}
    IO.inspect {source, from_coord}

    if no_keys_or_doors?(graph) do
      acc
    else
      throw "should hit in 1 pass"
      # djikstra(graph, from_coord, acc)
    end
  end

  def djikstra_process(time_graph, {dist, prev, q}, from_coord) do
    if MapSet.size(q) == 0 do
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
      current_time = u_dist

      if u_dist > 1_000_000 do
        {graph, dist, prev, from_coord}
      else
        q = MapSet.delete(q, u)

        {graph, change_coord} = modify_pickup(graph, u)
        next_from_cord = change_coord || from_coord

        {dist, prev} =
          neighbors(graph, q, u)
          |> Enum.reduce({dist, prev}, fn coord, {dist, prev} ->
            alt = u_dist + segment_size(graph, current_time, coord)

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

  def segment_size(graph, current_time, coord) do
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
