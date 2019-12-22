defmodule TwentyTwo do
  def solve(deck, instructions) do
    String.split(instructions, "\n", trim: true)
    |> Enum.reduce(deck, fn line, deck ->
      # IO.puts line
      next_deck = process(line, deck)

      IO.inspect Enum.at(next_deck, 2020)
      next_deck
      # if Enum.uniq(next_deck) == next_deck, do: next_deck
    end)
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
