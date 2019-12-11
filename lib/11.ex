defmodule Eleven do
  def computer(list) do
    Process.delete(:curr_output)
    nums = String.split(list, ",") |> Enum.map(&String.to_integer/1)

    positions = nums |> Enum.with_index() |> Enum.reduce(%{rb: 0}, fn {num, p}, acc ->
      Map.put(acc, p, num)
    end)

    processor(positions, 0)
  end

  def processor(p, i) do
    {instr, modes} = case instruction(Map.get(p, i), p, i) do
      ret = {_, _} -> ret
      instr -> {instr, {:p, :p, :p}}
    end

    debug({instr, modes})
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
      9 -> [9, Map.get(p, i+1)]
      99 -> [99]
      custom ->
        digits = Integer.digits(custom)
        unless length(digits) > 2, do: raise "Opcode #{opcode} not long enough"
        opcode = "#{Enum.at(digits, -2)}#{Enum.at(digits, -1)}" |> String.to_integer()
        first_mode = get_mode(Enum.at(digits, -3))
        second_mode = get_mode(Enum.at(digits, -4))
        third_mode = get_mode(Enum.at(digits, -5))

        {instruction(opcode, p, i), {first_mode, second_mode, third_mode}}
    end
  end

  def get_mode(nil), do: :p
  def get_mode(0), do: :p
  def get_mode(1), do: :i
  def get_mode(2), do: :r

  # Adjust relative base
  def process([9, p1], positions, index, {first_m, _, _}) do
    p1_v = value(positions, p1, first_m)
    cur_base = Map.fetch!(positions, :rb)

    result = Map.put(positions, :rb, cur_base + p1_v)

    processor(result, index + 2)
  end

  # Add
  def process([1, p1, p2, r], positions, index, {first_m, second_m, third_m}) do
    p1_v = value(positions, p1, first_m)
    p2_v = value(positions, p2, second_m)
    r = write_index(positions, r, third_m)

    result = Map.put(positions, r, p1_v + p2_v)

    processor(result, index + 4)
  end

  # Multiple
  def process([2, p1, p2, r], positions, index, {first_m, second_m, third_m}) do
    p1_v = value(positions, p1, first_m)
    p2_v = value(positions, p2, second_m)
    r = write_index(positions, r, third_m)

    debug {:mult, {p1_v, p2_v, p1_v * p2_v, r}}
    result = Map.put(positions, r, p1_v * p2_v)

    processor(result, index + 4)
  end

  # Input
  def process([3, p], positions, index, {mode, _, _}) do
    # curr = Process.get(:input_curr)
    # Process.put(:input_curr, curr + 1)
    last_output = Process.get(:curr_output) |> List.wrap() |> List.first()

    # next_input = Process.get(:test_input) |> List.wrap() |> Enum.at(curr, last_output)
    # IO.inspect "input: #{next_input}, #{Process.get(:curr_program)}"

    val = Process.get(:test_input).() |> String.trim() |> String.to_integer()
    p = write_index(positions, p, mode)
    result = Map.put(positions, p, val)

    debug "input: #{val} to #{p}"

    processor(result, index + 2)
  end

  # Output
  def process([4, p1], positions, index, {first_m, _second_m, _third_m}) do
    p1_v = value(positions, p1, first_m)

    output = List.wrap(Process.get(:curr_output))
    Process.put(:curr_output, ["#{p1_v}" | output])
    # IO.inspect "output: #{p1_v}"
    # Logger.info "Output: #{p1_v}"

    # {:pause, {positions, index + 2}}
    processor(positions, index + 2)
  end

  # jump-if-true
  def process([5, p1, p2], positions, index, {first_m, second_m, _}) do
    p1_v = value(positions, p1, first_m)
    p2_v = value(positions, p2, second_m)

    next = if p1_v != 0 do
      p2_v
    else
      index + 3
    end

    processor(positions, next)
  end

  # jump-if-false
  def process([6, p1, p2], positions, index, {first_m, second_m, _}) do
    p1_v = value(positions, p1, first_m)
    p2_v = value(positions, p2, second_m)

    next = if p1_v == 0 do
      p2_v
    else
      index + 3
    end

    debug {:jif, {p1_v, p2_v, next}}

    processor(positions, next)
  end

  # less-than
  def process([7, p1, p2, p3], positions, index, {first_m, second_m, third_m}) do
    p1_v = value(positions, p1, first_m)
    p2_v = value(positions, p2, second_m)
    p3 = write_index(positions, p3, third_m)

    result = if p1_v < p2_v do
      Map.put(positions, p3, 1)
    else
      Map.put(positions, p3, 0)
    end

    processor(result, index + 4)
  end

  # equals
  def process([8, p1, p2, p3], positions, index, {first_m, second_m, third_m}) do
    p1_v = value(positions, p1, first_m)
    p2_v = value(positions, p2, second_m)
    p3 = write_index(positions, p3, third_m)

    result = if p1_v == p2_v do
      Map.put(positions, p3, 1)
    else
      Map.put(positions, p3, 0)
    end

    processor(result, index + 4)
  end

  def process([99], positions, _index, {_, _, _}) do
    Map.get(positions, 0)
  end

  def value(positions, p, :p), do: Map.get(positions, p, 0)
  def value(positions, p, :r), do: Map.get(positions, p + Map.fetch!(positions, :rb), 0)
  def value(_positions, p, :i), do: p

  def write_index(_, p, :p), do: p
  def write_index(positions, p, :r), do: p + Map.fetch!(positions, :rb)

  def debug(terms) do
    # IO.inspect(terms, charlists: :as_lists)
  end
end
