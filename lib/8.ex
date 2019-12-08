defmodule Eight do
  def solve(input, {w, h}) do
    layers(input, w, h)
    |> Enum.map(fn layer ->
      {
        count_layer(layer, "0"),
        count_layer(layer, "1"),
        count_layer(layer, "2")
      }
    end)
    |> Enum.min_by(& elem(&1, 0))
  end

  defp count_layer(layer, char) do
    Enum.filter(layer, & &1 == char) |> length()
  end

  def decode(input, {w, h}) do
    layers(input, w, h)
    |> Enum.reverse()
    |> Enum.reduce(%{}, fn layer, acc ->
      layer
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {char, index}, acc ->
        if char != "2" do
          Map.put(acc, index, char)
        else
          acc
        end
      end)
    end)
  end

  def render(decoded, {w, h}) do
    if System.get_env("RENDER") == "1" do
      IO.write("\n")

      Enum.each(0..((w*h)-1), fn i ->
        char = Map.fetch!(decoded, i)

        case char do
          "1" -> IO.write(char)
          "0" -> IO.write(" ")
        end

        if rem(i + 1, w) == 0, do: IO.write("\n")
      end)

      IO.write("\n")
    end
  end

  defp layers(input, w, h) do
    String.graphemes(input) |> Enum.chunk_every(w * h)
  end
end
