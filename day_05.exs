defmodule Day5 do

  def trigger(polymer) do
    polymer |> to_charlist |> do_trigger |> to_string
  end

  defp do_trigger([]), do: []

  defp do_trigger([left | left_tail]) do

    case do_trigger(left_tail) do
      [ right | right_tail ] ->
        if abs(left - right) == 32 do
          do_trigger(right_tail)
        else
          [ left | do_trigger([right | right_tail]) ]
        end
      [] -> [ left | left_tail ]
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

    #test "test data for problem" do
      #polymer = File.read! "fixtures/day_05_polymer.txt"

      #assert trigger(polymer) == "lkjsf"
    #end
  end
end
