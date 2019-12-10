defmodule Ten do
  @moduledoc """
  Part 1 solves this in a brute force manner. It expands each asteroid location looking for asteroids it can see, via delta
  changes. Once it sees one, everything else in that expansion is marked as hidden. The final result is the differences between
  what it can see and what is hidden, sorted.

  Part 2 actually uses math. The degree between 2 points is calculated using atan formula I found online. Then the reduction
  starts at degree 269.9999 (close to 270, which is north). The reduction sorts all asteroids by the difference between their to-station
  degree and the last known angle. It adds 360 to the angle when it "comes around", so it will loop correctly.
  """

  def solve(input) do
    {map, _} =
      String.split(input, "\n")
      |> Enum.reduce({%{}, 0}, fn line, {acc, y} ->
        {acc, _} =
          line
          |> String.graphemes()
          |> Enum.reduce({acc, 0}, fn char, {acc, x} ->
            {
              Map.put(acc, {x, y}, %{asteroid: char == "#", see: MapSet.new(), hidden: MapSet.new()}),
              x + 1
            }
          end)

        {acc, y + 1}
      end)

    num_rows = Map.keys(map) |> Enum.map(& elem(&1, 1)) |> Enum.max()
    num_cols = Map.keys(map) |> Enum.map(& elem(&1, 0)) |> Enum.max()
    maxes = {num_cols, num_rows}

    {coords, %{hidden: hidden, see: see}} =
      map
      |> Enum.filter(fn {_, %{asteroid: a}} -> a end)
      |> Enum.into(%{})
      |> Map.keys()
      |> Enum.reduce(map, fn coords, map ->
        for x_d <- (-num_cols..num_cols), y_d <- (-num_rows..num_rows) do
          {x_d, y_d}
        end
        |> Enum.reduce(map, fn
          {0, 0}, map -> map
          delta, map ->
            expand_until_collision(map, coords, coords, delta, maxes, :see)
        end)
      end)
      |> Enum.sort_by(fn {_coords, %{hidden: hidden, see: see}} ->
        MapSet.difference(see, hidden) |> MapSet.size()
      end)
      |> Enum.reverse()
      |> List.first()

    {coords, MapSet.difference(see, hidden) |> MapSet.size()}
  end

  defp expand_until_collision(map, original, {x, y}, deltas = {x_delta, y_delta}, maxes = {x_max, y_max}, mode) do
    next = {next_x, next_y} = {x + x_delta, y + y_delta}

    if next_x < 0 || next_x > x_max || next_y < 0 || next_y > y_max do
      # hit border without collision
      map
    else
      next_space = Map.fetch!(map, next)

      if next_space.asteroid do
        base = Map.fetch!(map, original)
        base = Map.put(base, mode, MapSet.put(Map.fetch!(base, mode), next))
        map = Map.put(map, original, base)
        expand_until_collision(map, original, next, deltas, maxes, :hidden)
      else
        expand_until_collision(map, original, next, deltas, maxes, mode)
      end
    end
  end

  defmodule Two do
    def solve(input, station = {_, _}) do
      {map, _} =
        String.split(input, "\n")
        |> Enum.reduce({%{}, 0}, fn line, {acc, y} ->
          {acc, _} =
            line
            |> String.graphemes()
            |> Enum.reduce({acc, 0}, fn char, {acc, x} ->
              {
                Map.put(acc, {x, y}, %{asteroid: char == "#" and {x, y} != station, see: MapSet.new(), hidden: MapSet.new()}),
                x + 1
              }
            end)

          {acc, y + 1}
        end)

      num_rows = Map.keys(map) |> Enum.map(& elem(&1, 1)) |> Enum.max()
      num_cols = Map.keys(map) |> Enum.map(& elem(&1, 0)) |> Enum.max()
      maxes = {num_cols, num_rows}

      zap_asteroids(map, station, 269.9999, 1, nil)
    end

    def zap_asteroids(_, _, _, 201, last_coords), do: last_coords

    def zap_asteroids(map, station, angle, curr, _last_zapped) do
      {zap_coords, to_zap} =
        map
        |> Enum.filter(fn {_, %{asteroid: a}} -> a end)
        |> Enum.sort_by(fn {coords, _} ->
          degree = degree_between_points(station, coords)
          sort = cast_to_positive_degree(angle - degree)
          distance = distance_between_points(station, coords)
          # IO.inspect {coords, sort, degree, distance}

          sort = if degree <= angle do
            degree + 360
          else
            degree
          end

          {sort, distance}
        end)
        |> List.first()
        # |> IO.inspect

      degree = degree_between_points(station, zap_coords)
      # IO.puts "The #{curr} asteroid to be vaporized is at #{inspect zap_coords}, at #{degree} degree"
      map = Map.put(map, zap_coords, %{to_zap | asteroid: false})
      zap_asteroids(map, station, degree, curr + 1, zap_coords)
    end

    def degree_between_points({x, y}, {x2, y2}) do
      theta = :math.atan2(y2 - y, x2 - x)
      degree = theta * 180 / :math.pi()
      cast_to_positive_degree(degree)
    end

    def cast_to_positive_degree(degree) when degree < 0, do: degree + 360
    def cast_to_positive_degree(degree), do: degree

    def distance_between_points({x, y}, {x2, y2}) do
      :math.sqrt( :math.pow((x2 - x), 2) + :math.pow((y2 - y), 2) )
    end
  end
end
