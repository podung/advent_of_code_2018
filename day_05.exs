defmodule Day5 do

  def trigger(polymer) do
    polymer
    |> String.trim
    |> to_charlist
    |> do_trigger([])
    |> to_string
  end

  defp do_trigger([a], seen), do: Enum.reverse([a | seen])
  defp do_trigger([a,b | tail], seen = [ last_seen | seen_tail ]) do
    if abs(a - b) == 32 do
      do_trigger([ last_seen | tail], seen_tail)
    else
      do_trigger([b | tail], [ a | seen ])
    end
  end
  defp do_trigger([a,b | tail], seen = []) do
    if abs(a - b) == 32 do
      do_trigger(tail, seen)
    else
      do_trigger([ b | tail], [ a | seen])
    end
  end
end

ExUnit.start()

defmodule Day5Test do
  use ExUnit.Case

  import Day5

  describe "trigger" do
    test "examples" do
      assert trigger("dabAcCaCBAcCcaDA") == "dabCBAcaDA"
    end

    test "examples length" do
      assert trigger("dabAcCaCBAcCcaDA") |> String.length == 10
    end

    test "test data for problem" do
      polymer = File.read! "fixtures/day_05_polymer.txt"

      assert trigger(polymer) == File.read!("fixtures/day_05_expected.txt") |> String.trim
    end

    test "length answer" do
      polymer = File.read! "fixtures/day_05_polymer.txt"

      assert trigger(polymer) |> String.length == 9060
    end
  end
end
