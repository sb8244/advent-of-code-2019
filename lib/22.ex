defmodule TwentyTwo do
  defmodule Power do
    def power(x, n, _) when n == 1, do: x

    def power(x, n, mod) when rem(n, 2) == 0 do
      next_x = rem(x * x, mod)
      power(x * x, floor(n / 2), mod)
    end

    def power(x, n, mod) do
      next_x = rem(x * x, mod)
      x * power(next_x, floor((n - 1) / 2), mod)
    end
  end

  def solve(deck, instructions) do
    String.split(instructions, "\n", trim: true)
    |> Enum.reduce(deck, fn line, deck ->
      # IO.puts line
      next_deck = process(line, deck)

      # IO.inspect Enum.at(next_deck, 2020)
      next_deck
      # if Enum.uniq(next_deck) == next_deck, do: next_deck
    end)
  end

  def solve_2(deck_size, instructions, iterations) do
    {offset_diff, increment_mul} =
      String.split(instructions, "\n", trim: true)
      |> Enum.reduce({0, 1}, fn line, {offset, increment} ->
        process_2(deck_size, line, {offset, increment})
      end)

    offset = offset_diff * (1 - Power.power(increment_mul, iterations, deck_size)) * inverse(1 - increment_mul, deck_size)
    increment = Power.power(increment_mul, iterations, deck_size)

    {offset, increment}
  end

  def process_2(_, "deal into new stack", {offset, increment}) do
    new_incr = increment * -1
    {offset + new_incr, new_incr}
  end

  def process_2(_, "cut " <> amount_s, {offset, increment}) do
    amount = String.to_integer(amount_s)
    {offset + increment * amount, increment}
  end

  def process_2(size, "deal with increment " <> amount_s, {offset, increment}) do
    amount = String.to_integer(amount_s)
    {offset, increment * inverse(amount, size)}
  end

  def inverse(n, size) do
    Power.power(n, size - 2, size)
  end

  def process("deal into new stack", deck) do
    # IO.puts ("deal into new stack")
    Enum.reverse(deck)
  end

  def process("cut " <> amount_s, deck) do
    amount = String.to_integer(amount_s)
    # IO.puts("cut #{amount}")

    taken = Enum.take(deck, amount)
    rest = Enum.drop(deck, amount)

    cond do
      amount > 0 -> rest ++ taken
      amount < 0 -> taken ++ rest
    end
  end

  def process("deal with increment " <> amount_s, deck) do
    amount = String.to_integer(amount_s)
    # IO.puts ("deal with increment #{amount}")
    deal_increment(deck, %{}, amount, 0, length(deck))
  end

  def deal_increment([], new_deck, _, _curr, _) do
    new_deck
    |> Enum.to_list()
    |> Enum.sort_by(fn {pos, card} -> pos end)
    |> Enum.map(fn {_pos, card} -> card end)
  end

  def deal_increment([card | deck], new_deck, increment, curr_deck, dl) do
    if Enum.member?(new_deck, curr_deck), do: throw "Invalid position deal_increment"

    # The new deck has the card inserted at the right position
    new_deck = Map.put(new_deck, curr_deck, card)

    # We're going to go to the current spot with the increment
    next_curr_deck = rem(curr_deck + increment, dl)

    deal_increment(deck, new_deck, increment, next_curr_deck, dl)
  end
end
