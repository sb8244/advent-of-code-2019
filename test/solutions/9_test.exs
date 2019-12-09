defmodule NineTest do
  use ExUnit.Case

  test "example" do
    Nine.computer("109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99")
    assert Process.get(:curr_output) == ["99", "0", "101", "1006", "101", "16", "100", "1008", "100", "1", "100", "1001", "-1", "204", "1", "109"]

    Nine.computer("1102,34915192,34915192,7,4,7,99,0")
    assert [string] = Process.get(:curr_output)
    assert String.length(string) == 16

    Nine.computer("104,1125899906842624,99")
    assert Process.get(:curr_output) == ["1125899906842624"]
  end

  test "pt1" do
    Process.put(:input_curr, 0)
    Process.put(:test_input, ["1"])
    File.read!("9.in") |> String.trim() |> Nine.computer()
    assert Process.get(:curr_output) == ["2932210790"]
  end

  test "pt2" do
    Process.put(:input_curr, 0)
    Process.put(:test_input, ["2"])
    File.read!("9.in") |> String.trim() |> Nine.computer()
    assert Process.get(:curr_output) == ["73144"]
  end
end
