defmodule Sixteen do
  def solve_2(digits, {count, max}, _) when count == max do
    digits |> Enum.join()
  end

  def solve_2(digits, {count, max}, back_half_size) do
    full_length = length(digits)
    half_length = ceil(full_length / 2)
    front_size = full_length - back_half_size

    rev_digits = Enum.reverse(digits)
    half_digits = Enum.take(rev_digits, back_half_size)
    first_half_digits = Enum.take(digits, front_size)
    {next_back_half_digits, _sum} = Enum.reduce(half_digits, {[], 0}, fn digit, {acc, sum} ->
      next_sum = sum + digit
      next_digit = Integer.digits(next_sum) |> List.last()
      next_acc = [next_digit | acc]

      {next_acc, next_sum}
    end)

    (first_half_digits ++ next_back_half_digits)
    |> solve_2({count + 1, max}, back_half_size)
  end

  def solve(digits, {count, max}, _) when count == max do
    digits |> Enum.join()
  end

  def solve(digits, {count, max}, pattern \\ [0, 1, 0, -1]) do
    digit_length = length(digits)

    # IO.inspect digits

    digits
    |> Enum.with_index()
    |> Enum.map(fn {digit, index} ->
      Task.async(fn ->
        # IO.inspect :erlang.system_time(:millisecond)

        [first | pattern] = Enum.map(pattern, fn pdigit ->
          Enum.map((1..index + 1), fn _ -> [pdigit] end)
        end) |> List.flatten()

        Stream.cycle(pattern ++ [first])
        |> Stream.zip(digits)
        |> Stream.reject(fn {pattern, digit} -> pattern == 0 or digit == 0 end)
        |> Stream.map(fn {pattern, digit} -> pattern * digit end)
        |> Stream.take(digit_length)
        |> Enum.sum()
        |> abs()
        |> Integer.digits()
        |> List.last()
      end)
    end)
    |> Enum.map(&Task.await/1)
    |> solve({count + 1, max}, pattern)
  end
end
