defmodule Day2 do

  def checksum_part1(input) do
    input
    |> split_lines
    |> count_letters_per_line
    |> count_words_with_two_and_words_with_three_of_same_letter
    |> calculate_checksum
  end

  defp split_lines(input), do: String.split(input, "\n", trim: true)

  defp count_letters_per_line(ids) do
    Enum.map(ids, &count_letters(&1))
  end

  defp count_letters(id) do
    id
    |> String.graphemes
    |> Enum.reduce(%{}, &process_letter(&1, &2))
  end

  defp process_letter(letter, acc) do
    Map.update(acc, letter, 1, &(&1 + 1))
  end

  defp count_words_with_two_and_words_with_three_of_same_letter(ids) do
    starting_counts = %{two: 0, three: 0}

    Enum.reduce(ids, starting_counts, fn letter_counts, acc ->
      acc
      |> increment_if_has_exactly_any_two_letters(letter_counts)
      |> increment_if_has_exactly_any_three_letters(letter_counts)
    end)
  end

  defp increment_if_has_exactly_any_two_letters(acc, letter_count) do
    if has_any_letter_exactly_n_times(letter_count, 2),
      do: %{ acc | two: acc.two + 1},
      else: acc
  end

  defp increment_if_has_exactly_any_three_letters(acc, letter_count) do
    if has_any_letter_exactly_n_times(letter_count, 3),
      do: %{ acc | three: acc.three + 1},
      else: acc
  end

  defp has_any_letter_exactly_n_times(letter_count, n) do
    Enum.any?(letter_count, fn { _, value } -> value === n end)
  end

  defp calculate_checksum(%{ three: three_count, two: two_count }) do
    three_count * two_count
  end
end

ExUnit.start()

defmodule Day2Test do
  use ExUnit.Case

  import Day2

  describe "checksum part1" do
    test "checksum example scenarios" do
      assert checksum_part1("""
                            abcdef
                            bababc
                            abbcde
                            abcccd
                            aabcdd
                            abcdee
                            ababab
                            """) == 12
    end

    test "IDS for given for problem" do
      ids = File.read! "fixtures/day_02_IDS.txt"

      assert checksum_part1(ids) == 8610
    end
  end
end
