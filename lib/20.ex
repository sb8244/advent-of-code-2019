defmodule Twenty do
  def solve(input) do
    {map, warps} = extract(input)
    {start, "AA"} = Enum.find(warps, fn {_, char} -> char == "AA" end)
    {goal, "ZZ"} = Enum.find(warps, fn {_, char} -> char == "ZZ" end)

    bfs({map, warps, goal}, [{start, 0}], MapSet.new([start]))
  end

  def solve_2(input) do
    {map, warps} = extract(input)
    warps_location = warps_location(map, warps)
    {start, "AA"} = Enum.find(warps, fn {_, char} -> char == "AA" end)
    {goal, "ZZ"} = Enum.find(warps, fn {_, char} -> char == "ZZ" end)

    bfs2({map, warps, warps_location, {goal, 0}}, [{{start, 0}, 0}], MapSet.new([{start, 0}]))
  end

  def warps_location(map, warps) do
    max_c = Enum.map(map, fn {{c, _}, _} -> c end) |> Enum.max()
    max_r = Enum.map(map, fn {{_, r}, _} -> r end) |> Enum.max()

    Enum.reduce(warps, %{}, fn {{c, r}, _}, warp_locations ->
      if c == 2 or c == max_c - 2 or r == 2 or r == max_r - 2 do
        Map.put(warp_locations, {c, r}, :outer)
      else
        Map.put(warp_locations, {c, r}, :inner)
      end
    end)
  end

  def bfs(_, [], _), do: :fail
  def bfs(bundle = {map, warps, goal}, [{curr, count} | q], visited) do
    if curr == goal do
      count
    else
      {neighbors, warp_neighbors} = neighbors({map, warps}, curr)

      next_nodes =
        (neighbors ++ warp_neighbors)
        |> Enum.reject(& MapSet.member?(visited, &1))
        |> Enum.map(fn coords -> {coords, count + 1} end)

      next_visited = Enum.reduce(next_nodes, visited, fn {coords, _}, visited ->
        MapSet.put(visited, coords)
      end)

      next_q = q ++ next_nodes

      bfs(bundle, next_q, next_visited)
    end
  end

  def bfs2(_, [], _), do: :fail
  def bfs2(bundle = {map, warps, warps_location, goal}, [{curr = {_, _}, count} | q], visited) do
    # IO.inspect curr
    if curr == goal do
      count
    else
      {neighbors, warp_neighbors} = depth_neighbors({map, warps, warps_location}, curr)

      next_nodes =
        (neighbors ++ warp_neighbors)
        |> Enum.reject(& MapSet.member?(visited, &1))
        |> Enum.map(fn coords -> {coords, count + 1} end)

      next_visited = Enum.reduce(next_nodes, visited, fn {coords, _}, visited ->
        MapSet.put(visited, coords)
      end)

      next_q = q ++ next_nodes

      bfs2(bundle, next_q, next_visited)
    end
  end

  def depth_neighbors({map, warps, warps_location}, {curr, depth}) do
    {neighbors, warps} = neighbors({map, warps}, curr)

    neighbors = Enum.map(neighbors, & {&1, depth})
    warps =
      Enum.map(warps, fn to ->
        case Map.fetch!(warps_location, to) do
          :outer -> {to, depth + 1}
          :inner -> {to, depth - 1}
        end
      end)
      |> Enum.filter(fn {_, depth} -> depth >= 0 end)

    {neighbors, warps}
  end

  def neighbors({map, warps}, curr = {c, r}) do
    coords = [{c-1, r}, {c+1, r}, {c, r-1}, {c, r+1}]
    warp_coord = case Enum.find(warps, fn {possible_warp, _} -> possible_warp == curr end) do
      nil -> []
      {_, "AA"} -> []
      {_, "ZZ"} -> []
      {^curr, warp_match} ->
        {warp_coords, ^warp_match} = Enum.find(warps, fn {pos_warp, pos_match} -> pos_warp != curr and pos_match == warp_match end)
        # IO.inspect "Warp found #{inspect warp_coords}, #{warp_match}"
        [warp_coords]
    end

    {Enum.filter(coords, fn coord ->
      Map.get(map, coord) == ?.
    end), warp_coord}
  end

  def extract(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce({%{}, %{}}, fn {line, r}, acc ->
      String.split(line, "", trim: true)
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {str, c}, {map, warps} ->
        [char] = String.to_charlist(str)
        map = Map.put(map, {c, r}, char)
        left_char = Map.get(map, {c-1, r}, ?-)
        up_char = Map.get(map, {c, r-1}, ?-)

        warps =
          if char in (?A..?Z) and left_char in (?A..?Z) do
            warp_point = "#{[left_char]}#{[char]}"

            ll_char = Map.get(map, {c-2, r}, ?-)
            r_char = Map.get(map, {c+1, r}, ?-)
            warp_coord = if ll_char == ?., do: {c-2, r}, else: {c+1, r}

            Map.put(warps, warp_coord, warp_point)
          else
            if char in (?A..?Z) and up_char in (?A..?Z) do
              warp_point = "#{[up_char]}#{[char]}"

              uu_char = Map.get(map, {c, r-2}, ?-)
              d_char = Map.get(map, {c, r+1}, ?-)
              warp_coord = if uu_char == ?., do: {c, r-2}, else: {c, r+1}

              Map.put(warps, warp_coord, warp_point)
            else
              warps
            end
          end

        {map, warps}
      end)
    end)
  end
end
