defmodule One do
  def solution(input, fuel_cost) do
    String.split(input)
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&get_fuel(&1, fuel_cost))
    |> Enum.sum()
  end

  def get_fuel(num, _) when num <= 0, do: 0

  def get_fuel(num, false) do
    Integer.floor_div(num, 3) - 2
  end

  def get_fuel(num, true) do
    res = coerce(Integer.floor_div(num, 3) - 2)
    res + get_fuel(res, true)
  end

  def coerce(num) when num <= 0, do: 0
  def coerce(num), do: num
end
