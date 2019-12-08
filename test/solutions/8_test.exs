defmodule EightTest do
  use ExUnit.Case

  test "pt1" do
    {_, one, two} = File.read!("8.in") |> String.trim() |> Eight.solve({25, 6})
    assert one * two == 2159
  end

  test "pt2" do
    # Must visualize with RENDER=1
    Eight.decode("0222112222120000", {2, 2}) |> Eight.render({2, 2})
    File.read!("8.in") |> String.trim() |> Eight.decode({25, 6}) |> Eight.render({25, 6})
    # CJZHR
  end
end
