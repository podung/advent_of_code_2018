defmodule Day5 do

  def trigger(polymer) do
    polymer
    |> String.trim
    |> String.codepoints
    |> Enum.reduce([], &react/2)
    |> Enum.reverse
    |> Enum.join
  end

  def trigger_part2(polymer) do
    polymer
    |> String.trim
    |> String.codepoints
    |> Enum.reduce({ [], %{} }, &react_test/2)
    |> select_shortest_polymer
    |> Enum.reverse
    |> Enum.join
  end

  defp react_test(current, { full, candidates } ) do
    candidates = candidates
                 |> Map.put_new(String.upcase(current), full)
                 |> Enum.map(&(filter_or_react(current, &1)))
                 |> Enum.into(%{})


    { react(current, full), candidates }
  end

  defp filter_or_react(current, { key, value }) do
    if String.upcase(current) == key do
      { key, value }
    else
      { key, react(current, value) }
    end
  end

  defp select_shortest_polymer({ _full, shortest_candidates}) do
    shortest_candidates
    |> Enum.min_by(fn { _key, polymer } -> length(polymer) end)
    |> elem(1)
  end

  defp react(current, []), do: [current]

  defp react(current, [last | tail]) do
    if !should_throw_out(current, last),
      do: [ current, last | tail],
      else: tail
  end

  defp should_throw_out(current, last) do
    current != last && String.upcase(current) == String.upcase(last)
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

  describe "trigger_part2" do
    test "examples" do
      assert trigger_part2("dabAcCaCBAcCcaDA") == "daDA"
    end

    test "examples length" do
      assert trigger_part2("dabAcCaCBAcCcaDA") |> String.length == 4
    end

    test "length answer" do
      polymer = File.read! "fixtures/day_05_polymer.txt"

      assert trigger_part2(polymer) |> String.length == 6310
    end
  end
end
