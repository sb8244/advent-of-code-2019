defmodule Twelve do
  def solve(bodies, times) do
    Enum.reduce((1..times), bodies, fn _, bodies ->
      bodies
      |> apply_gravity()
      |> apply_velocities()
      # |> IO.inspect()
    end)
    |> total_energy()
    |> Enum.sum()
    # |> IO.inspect()
  end

  def solve_pt2(bodies) do
    {x, y, z} = solve_pt2(bodies, %{}, %{}, %{}, 0)
    [x, y, z] = [map_size(x), map_size(y), map_size(z)]

    lcm(lcm(x, y), z)
  end

  # Find repeat state
  def solve_pt2(bodies, xseen, yseen, zseen, count) do
    new_bodies =
      bodies
      |> apply_gravity()
      |> apply_velocities()

    xs = extract_fields(new_bodies, 0)
    ys = extract_fields(new_bodies, 1)
    zs = extract_fields(new_bodies, 2)

    if Map.has_key?(xseen, xs) and Map.has_key?(yseen, ys) and Map.has_key?(zseen, zs) do
      {xseen, yseen, zseen}
    else
      xseen = Map.put(xseen, xs, count)
      yseen = Map.put(yseen, ys, count)
      zseen = Map.put(zseen, zs, count)

      solve_pt2(new_bodies, xseen, yseen, zseen, count + 1)
    end
  end

  def extract_fields(bodies, num) do
    bodies |> Enum.map(fn {_key, {p, v}} -> {Enum.at(p, num), Enum.at(v, num)} end)
  end

  def gcd(a,0), do: abs(a)
  def gcd(a,b), do: gcd(b, rem(a,b))

  def lcm(a,b), do: div(abs(a*b), gcd(a,b))

  def apply_gravity(bodies) do
    keys = Map.keys(bodies)

    for a <- (0..2), b <- (a + 1..3), part <- (0..2), reduce: bodies do
      bodies ->
        one_key = Enum.at(keys, a)
        two_key = Enum.at(keys, b)
        {one_pos, one_vec} = Map.fetch!(bodies, one_key)
        {two_pos, two_vec} = Map.fetch!(bodies, two_key)

        one = Enum.at(one_pos, part)
        one_speed = Enum.at(one_vec, part)
        two = Enum.at(two_pos, part)
        two_speed = Enum.at(two_vec, part)

        {new_one, new_two} = cond do
          one < two -> {one_speed + 1, two_speed - 1}
          one > two -> {one_speed - 1, two_speed + 1}
          true -> {one_speed, two_speed}
        end

        new_o = {one_pos, List.replace_at(one_vec, part, new_one)}
        new_t = {two_pos, List.replace_at(two_vec, part, new_two)}

        bodies
        |> Map.put(one_key, new_o)
        |> Map.put(two_key, new_t)
    end
  end

  def apply_velocities(bodies) do
    bodies
    |> Enum.map(fn {key, {[x, y, z], vec = [vx, vy, vz]}} ->
      {key, {[x + vx, y + vy, z + vz], vec}}
    end)
    |> Enum.into(%{})
  end

  def total_energy(bodies) do
    bodies
    |> Enum.map(fn {_, {pos, vec}} ->
      potential = Enum.map(pos, &abs/1) |> Enum.sum()
      kinetic = Enum.map(vec, &abs/1) |> Enum.sum()
      potential * kinetic
    end)
  end
end
