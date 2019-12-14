defmodule Fourteen do
  def solve(input, need_count \\ 1) do
    material_map = materials(input)
    calculate_needs(material_map, [{"FUEL", need_count}], %{}, 0)
  end

  @ore 1_000_000_000_000

  # This could be more efficient, it will never be 1-1, doesn't affect run-time
  def solve_2(input), do: solve_2(input, {0, @ore})

  def solve_2(input, {min, max}) when min + 1 == max do
    test = solve(input, max)

    if test > @ore do
      min
    else
      max
    end
  end

  def solve_2(input, {min, max}) do
    middle = ceil((max - min) / 2) + min
    answer = solve(input, middle)

    next_range =
      cond do
        answer < @ore -> {middle, max}
        answer > @ore -> {min, middle}
      end

    solve_2(input, next_range)
  end

  def calculate_needs(_, [], _, ores), do: ores

  def calculate_needs(materials, [{"ORE", qty} | unmet], have, ore_count) do
    calculate_needs(materials, unmet, have, ore_count + qty)
  end

  def calculate_needs(materials, [{next_type, need_qty} | unmet], have, ore_count) do
    material = Map.fetch!(materials, next_type)
    create_qty = Map.fetch!(material, :quantity)
    have_qty = Map.get(have, next_type, 0)
    {next_have_qty, produce_times} = produce_count(have_qty, need_qty, create_qty)

    # IO.inspect {next_type, need_qty, have_qty, create_qty, next_have_qty, produce_times}

    next_unmet =
      if produce_times == 0 do
        unmet
      else
        require_list =
          material
          |> Map.fetch!(:requires)
          |> Map.to_list()
          |> Enum.map(fn {name, count} -> {name, count * produce_times} end)

        unmet ++ require_list
      end

    next_have = Map.put(have, next_type, next_have_qty - need_qty)

    calculate_needs(materials, next_unmet, next_have, ore_count)
  end

  def produce_count(have, need, create) when have < need do
    count = ceil((need - have) / create)
    {count * create + have, count}
  end

  def produce_count(have, _, _), do: {have, 0}

  def materials(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.reduce(%{}, fn line, material_map ->
      [input, output] = String.split(line, " => ")
      [output_qty, output_type] = String.split(output, " ")
      req_list = String.split(input, ", ")
      requires = Enum.reduce(req_list, %{}, fn material, acc ->
        [qty, type] = String.split(material, " ")
        Map.put(acc, type, String.to_integer(qty))
      end)

      if Map.has_key?(material_map, output_type), do: throw "Output already present"

      Map.put(material_map, output_type, %{
        quantity: String.to_integer(output_qty),
        requires: requires
      })
    end)
  end
end
