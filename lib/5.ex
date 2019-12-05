defmodule Five do
  require Logger

  def solve(list) do
    nums = String.split(list, ",") |> Enum.map(&String.to_integer/1)

    positions = nums |> Enum.with_index() |> Enum.reduce(%{}, fn {num, p}, acc ->
      Map.put(acc, p, num)
    end)

    processor(positions, 0)
  end

  def processor(p, i) do
    {instr, modes} = case instruction(Map.get(p, i), p, i) do
      ret = {_, _} -> ret
      instr -> {instr, {:p, :p, :p}}
    end

    debug({instr, modes}, charlists: :as_lists)
    process(instr, p, i, modes)
  end

  def instruction(opcode, p, i) do
    case opcode do
      1 -> [1, Map.get(p, i+1), Map.get(p, i+2), Map.get(p, i+3)]
      2 -> [2, Map.get(p, i+1), Map.get(p, i+2), Map.get(p, i+3)]
      3 -> [3, Map.get(p, i+1)]
      4 -> [4, Map.get(p, i+1)]
      5 -> [5, Map.get(p, i+1), Map.get(p, i+2)]
      6 -> [6, Map.get(p, i+1), Map.get(p, i+2)]
      7 -> [7, Map.get(p, i+1), Map.get(p, i+2), Map.get(p, i+3)]
      8 -> [8, Map.get(p, i+1), Map.get(p, i+2), Map.get(p, i+3)]
      99 -> [99]
      custom ->
        digits = Integer.digits(custom)
        opcode = "#{Enum.at(digits, -2)}#{Enum.at(digits, -1)}" |> String.to_integer()
        first_mode = if Enum.at(digits, -3) == 1, do: :i, else: :p
        second_mode = if Enum.at(digits, -4) == 1, do: :i, else: :p
        third_mode = if Enum.at(digits, -5) == 1, do: :i, else: :p

        {instruction(opcode, p, i), {first_mode, second_mode, third_mode}}
    end
  end

  # jump-if-true
  def process([5, p1, p2], positions, index, {first_m, second_m, _}) do
    p1_v = case first_m do
      :p -> Map.get(positions, p1, 0)
      :i -> p1
    end
    p2_v = case second_m do
      :p -> Map.get(positions, p2, 0)
      :i -> p2
    end

    next = if p1_v != 0 do
      p2_v
    else
      index + 3
    end

    processor(positions, next)
  end

  # jump-if-false
  def process([6, p1, p2], positions, index, {first_m, second_m, _}) do
    p1_v = case first_m do
      :p -> Map.get(positions, p1, 0)
      :i -> p1
    end
    p2_v = case second_m do
      :p -> Map.get(positions, p2, 0)
      :i -> p2
    end

    next = if p1_v == 0 do
      p2_v
    else
      index + 3
    end

    processor(positions, next)
  end

  # less-than
  def process([7, p1, p2, p3], positions, index, {first_m, second_m, _third_m}) do
    p1_v = case first_m do
      :p -> Map.get(positions, p1, 0)
      :i -> p1
    end
    p2_v = case second_m do
      :p -> Map.get(positions, p2, 0)
      :i -> p2
    end

    result = if p1_v < p2_v do
      Map.put(positions, p3, 1)
    else
      Map.put(positions, p3, 0)
    end

    processor(result, index + 4)
  end

  # equals
  def process([8, p1, p2, p3], positions, index, {first_m, second_m, _third_m}) do
    p1_v = case first_m do
      :p -> Map.get(positions, p1, 0)
      :i -> p1
    end
    p2_v = case second_m do
      :p -> Map.get(positions, p2, 0)
      :i -> p2
    end

    result = if p1_v == p2_v do
      Map.put(positions, p3, 1)
    else
      Map.put(positions, p3, 0)
    end

    processor(result, index + 4)
  end

  # Add
  def process([1, p1, p2, r], positions, index, {first_m, second_m, _third_m}) do
    debug({:add, p1, p2, r})
    p1_v = case first_m do
      :p -> Map.get(positions, p1, 0)
      :i -> p1
    end

    p2_v = case second_m do
      :p -> Map.get(positions, p2, 0)
      :i -> p2
    end

    result = Map.put(positions, r, p1_v + p2_v)

    processor(result, index + 4)
  end

  # Multiple
  def process([2, p1, p2, r], positions, index, {first_m, second_m, _third_m}) do
    debug({:mult, p1, p2, r})

    p1_v = case first_m do
      :p -> Map.get(positions, p1, 0)
      :i -> p1
    end

    p2_v = case second_m do
      :p -> Map.get(positions, p2, 0)
      :i -> p2
    end

    result = Map.put(positions, r, p1_v * p2_v)

    processor(result, index + 4)
  end

  # Input
  def process([3, p], positions, index, _) do
    debug({:input, p})

    val = Process.get(:test_input) |> String.trim() |> String.to_integer()
    result = Map.put(positions, p, val)

    processor(result, index + 2)
  end

  # Output
  def process([4, p1], positions, index, {first_m, _second_m, _third_m}) do
    debug({:output, p1})
    p1_v = case first_m do
      :p -> Map.get(positions, p1, 0)
      :i -> p1
    end

    Logger.info "Output: #{p1_v}"

    processor(positions, index + 2)
  end

  def process([99], positions, index, {_, _, _}) do
    debug(:done)

    Map.get(positions, 0)
  end

  def debug(terms, opts \\ []) do
    # IO.inspect(terms, opts)
  end
end
