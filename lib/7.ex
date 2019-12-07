defmodule Seven do
  @signals (for a <- 0..4, b <- 0..4, c <- 0..4, d <- 0..4, e <- 0..4 do
    if length(Enum.uniq([a, b, c, d, e])) == 5 do
      [a, b, c, d, e] |> Enum.map(&to_string/1)
    end
  end |> Enum.reject(&is_nil/1))

  @feedback (for a <- 5..9, b <- 5..9, c <- 5..9, d <- 5..9, e <- 5..9 do
    if length(Enum.uniq([a, b, c, d, e])) == 5 do
      [a, b, c, d, e] |> Enum.map(&to_string/1)
    end
  end |> Enum.reject(&is_nil/1))

  def solve(input) do
    {pattern, [value | _]} =
      Enum.map(@signals, fn process_input ->
        {process_input, Enum.reduce(process_input, [], fn test_input, acc ->
          previous = List.first(acc) || "0"

          Process.put(:test_input, [test_input, previous])
          Process.put(:input_curr, 0)
          Process.delete(:curr_output)

          computer(input)

          output = Process.get(:curr_output) |> List.first()
          [output | acc]
        end)}
      end)
      |> Enum.max_by(fn {_, [num | _]} -> String.to_integer(num) end)

    {Enum.join(pattern), value}
  end

  def solve_2_trash(input) do
    {pattern, [value | _]} =
      Enum.map([["9","8","7","6","5"]], fn process_input ->
        {
          process_input,
          Enum.reduce(process_input, {[], %{}}, fn test_input, {acc, val} ->
            previous = List.first(acc) || "0"

            Process.put(:test_input, [test_input, previous])
            Process.put(:input_curr, 0)
            Process.delete(:curr_output)

            computer(input)

            output = Process.get(:curr_output) |> List.first()
            [output | acc]
          end)
        }
      end)
      |> IO.inspect()
      |> Enum.max_by(fn {_, [num | _]} -> String.to_integer(num) end)

    {Enum.join(pattern), value}
  end

  def solve_2(input) do
    {pattern, value} =
      Enum.map(@feedback, fn process_input = [a, b, c, d, e] ->
        Process.delete(:curr_output)

        inputs = %{0 => [a, "0"], 1 => [b], 2 => [c], 3 => [d], 4 => [e]}
        output = engage_thrusters(input, 0, inputs, %{})

        { process_input, output }
      end)
      |> Enum.max_by(fn {_, num} -> String.to_integer(num) end)

    {Enum.join(pattern), value}

  end

  def engage_thrusters(program, curr_program, inputs, states) do
    inputs = case Map.get(inputs, curr_program) do
      nil ->
        Process.delete(:test_input)
        inputs

      next_input ->
        Process.put(:test_input, List.wrap(next_input))
        Process.put(:input_curr, 0)

        Map.delete(inputs, curr_program)
    end

    Process.put(:curr_program, curr_program)

    result = case Map.get(states, curr_program) do
      {positions, index} -> processor(positions, index)
      _ -> computer(program)
    end

    case result do
      {:pause, state} ->
        output = Process.get(:curr_output) |> List.first()
        next_program = rem(curr_program + 1, 5)
        next_program_inputs = Map.get(inputs, next_program)

        states = Map.put(states, curr_program, state)

        engage_thrusters(program, next_program, inputs, states)

      _ ->
        output = Process.get(:curr_output) |> List.first()
        next_program = rem(curr_program + 1, 5)
        next_program_inputs = Map.get(inputs, next_program)

        states = Map.put(states, curr_program, :halt)

        if Map.values(states) |> Enum.uniq() == [:halt] do
          output
        else
          engage_thrusters(program, next_program, inputs, states)
        end
    end
  end

  # From 5.ex

  require Logger

  def computer(list) do
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

  # Add
  def process([1, p1, p2, r], positions, index, {first_m, second_m, _third_m}) do
    p1_v = value(positions, p1, first_m)
    p2_v = value(positions, p2, second_m)

    result = Map.put(positions, r, p1_v + p2_v)

    processor(result, index + 4)
  end

  # Multiple
  def process([2, p1, p2, r], positions, index, {first_m, second_m, _third_m}) do
    p1_v = value(positions, p1, first_m)
    p2_v = value(positions, p2, second_m)

    result = Map.put(positions, r, p1_v * p2_v)

    processor(result, index + 4)
  end

  # Input
  def process([3, p], positions, index, _) do
    curr = Process.get(:input_curr)
    Process.put(:input_curr, curr + 1)
    last_output = Process.get(:curr_output) |> List.wrap() |> List.first()

    next_input = Process.get(:test_input) |> List.wrap() |> Enum.at(curr, last_output)
    # IO.inspect "input: #{next_input}, #{Process.get(:curr_program)}"

    val = next_input |> String.trim() |> String.to_integer()
    result = Map.put(positions, p, val)

    processor(result, index + 2)
  end

  # Output
  def process([4, p1], positions, index, {first_m, _second_m, _third_m}) do
    p1_v = value(positions, p1, first_m)

    output = List.wrap(Process.get(:curr_output))
    Process.put(:curr_output, ["#{p1_v}" | output])
    # IO.inspect "output: #{p1_v}"
    # Logger.info "Output: #{p1_v}"

    {:pause, {positions, index + 2}}
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

    processor(positions, next)
  end

  # less-than
  def process([7, p1, p2, p3], positions, index, {first_m, second_m, _third_m}) do
    p1_v = value(positions, p1, first_m)
    p2_v = value(positions, p2, second_m)

    result = if p1_v < p2_v do
      Map.put(positions, p3, 1)
    else
      Map.put(positions, p3, 0)
    end

    processor(result, index + 4)
  end

  # equals
  def process([8, p1, p2, p3], positions, index, {first_m, second_m, _third_m}) do
    p1_v = value(positions, p1, first_m)
    p2_v = value(positions, p2, second_m)

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
  def value(_positions, p, :i), do: p

  def debug(_terms) do
    # IO.inspect(terms, charlists: :as_lists)
  end
end
