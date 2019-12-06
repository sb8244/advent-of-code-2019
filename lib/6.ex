defmodule Six do
  def solve(input) do
    graph = construct(input, :dag)

    graph
    |> Map.keys()
    |> Enum.map(fn key ->
      traverse(graph, [key], 0)
    end)
    |> Enum.sum()
  end

  def shortest(input) do
    graph = construct(input, :g)
    find_santa(graph, "YOU", %{}, 0)
  end

  def construct(input, type) do
    input
    |> String.split("\n")
    |> Enum.reduce(%{}, fn line, acc ->
      [left, right] = String.split(line, ")")

      acc = Map.put(acc, right, [left | Map.get(acc, right, [])])

      case type do
        :dag -> acc
        :g -> Map.put(acc, left, [right | Map.get(acc, left, [])])
      end
    end)
  end

  def traverse(_, [], count), do: count - 1
  def traverse(graph, [curr | frontier], count) do
    neighbors = Map.get(graph, curr, [])
    next = Enum.uniq(List.flatten([neighbors | frontier]))
    traverse(graph, next, count + 1)
  end

  def find_santa(_graph, "SAN", _, count), do: count - 2
  def find_santa(graph, curr, visited, count) do
    visited = Map.put(visited, curr, true)
    neighbors = Map.get(graph, curr, []) |> Enum.reject(&Map.get(visited, &1))

    # I know this isn't the most efficient, but it runs fast on the input still
    neighbors
    |> Enum.map(fn next ->
      find_santa(graph, next, visited, count + 1)
    end)
    |> Enum.find(&(!is_nil(&1)))
  end
end
