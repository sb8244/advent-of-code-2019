defmodule Four do
  def solve({low, high}, adjacent \\ true) do
    Enum.filter(low..high, fn num ->
      is_match?(num, adjacent)
    end)
    |> length()
  end

  def is_match?(number, adjacent \\ true) do
    a = rem(number, 10)
    number = div(number, 10)

    b = rem(number, 10)
    number = div(number, 10)

    c = rem(number, 10)
    number = div(number, 10)

    d = rem(number, 10)
    number = div(number, 10)

    e = rem(number, 10)
    number = div(number, 10)

    f = rem(number, 10)
    number = div(number, 10)

    monotonic = f <= e && e <= d && d <= c && c <= b && b <= a

    if adjacent do
      monotonic && (f == e || e == d || d == c || c == b || b == a)
    else
      l = [f, e, d, c, b, a]

      triple_nums =
        Enum.chunk_every(l, 3, 1, :discard)
        |> Enum.filter(fn
          [a, a, a] -> true
          _ -> false
        end)
        |> List.flatten()

      double_nums =
        Enum.chunk_every(l, 2, 1, :discard)
        |> Enum.filter(fn
          [a, a] -> true
          _ -> false
        end)
        |> List.flatten()

      # IO.inspect {l, triple_nums, double_nums}
      # IO.inspect {l, triple_count, double_count, triple_count + 2 <= double_count}

      # It turns out that a triple can never appear in a double, due to the monotonic property.
      monotonic && length(Enum.uniq(double_nums)) > length(Enum.uniq(triple_nums)) # triple_count + 2 <= double_count
    end
  end
end
