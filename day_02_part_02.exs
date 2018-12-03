defmodule Day2Part2 do
  def doit(input) do
    input
    |> parse_ids
    |> create_all_combinations
    |> Enum.map(&zip_letters/1)
    |> Enum.find(&differs_by_single_letter?/1)
    |> Enum.reject(&differing_letters/1)
    |> Enum.map(&unify_letter_pairs/1)
    |> List.to_string
  end

  defp parse_ids(input), do: String.split(input, "\n", trim: true)

  defp create_all_combinations(ids) do
    ids
    |> combinize
    |> List.flatten
  end

  defp combinize([]), do: []

  defp combinize([left|tail]) do
    [
      combinize(tail) | Enum.map(tail, fn right ->
        { String.graphemes(left), String.graphemes(right) }
      end)
    ]
  end

  defp zip_letters({ left, right }), do: Enum.zip(left, right)

  defp differs_by_single_letter?(letter_pairs), do: offby_count(letter_pairs) == 1

  defp offby_count(letter_pairs) do
    Enum.reduce(letter_pairs, 0,
      fn({ left, right }, offby_count) ->
        case left == right do
          true -> offby_count
          false -> offby_count + 1
        end
      end)
  end

  defp differing_letters({ left, right}), do: left != right
  defp unify_letter_pairs({left, _}), do: left
end

ExUnit.start()

defmodule Day2Part2Test do
  use ExUnit.Case

  import Day2Part2

  describe "doit" do
    test "example scenarios" do
      assert doit("""
                  abcde
                  fghij
                  klmno
                  pqrst
                  fguij
                  axcye
                  wvxyz
                  """) == "fgij"
    end

    test "IDS for given for problem" do
      ids = File.read! "fixtures/day_02_IDS.txt"

      assert doit(ids) == "iosnxmfkpabcjpdywvrtahluy"
    end
  end
end
