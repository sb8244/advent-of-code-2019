defmodule Sixteen do
  def solve_2(digits, max, first_seven) do
    reversed = digits |> Enum.drop(first_seven) |> Enum.reverse()
    do_solve_2(reversed, {0, max})
  end

  def do_solve_2(digits, {count, max}) when count == max do
    Enum.take(digits, -8) |> Enum.reverse() |> Enum.join()
  end

  def do_solve_2(digits, {count, max}) do
    {next_digits, _sum} =
      Enum.reduce(digits, {[], 0}, fn digit, {acc, sum} ->
        next_sum = sum + digit
        next_acc = [rem(next_sum, 10) | acc]

        {next_acc, next_sum}
      end)

    next_digits
    |> Enum.reverse()
    |> do_solve_2({count + 1, max})
  end

  def solve(digits, {count, max}, _) when count == max do
    digits |> Enum.join()
  end

  def solve(digits, {count, max}, pattern \\ [0, 1, 0, -1]) do
    digit_length = length(digits)

    IO.inspect digits

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
