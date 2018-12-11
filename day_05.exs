defmodule Day5 do

  def trigger(polymer) do
    polymer
    |> String.trim
    |> String.to_charlist
    |> Enum.reduce([], &react/2)
    |> Enum.reverse
    |> to_string
  end

  defp react(current, []), do: [current]

  defp react(current, [last | processed_tail])
    when abs(current - last) == 32, do: processed_tail

  defp react(current, processed), do: [ current | processed ]
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
