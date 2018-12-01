defmodule Exercise1 do
  def calibrate(frequencies) when is_binary frequencies do
    frequencies
    |> String.split("\n", trim: true)
    |> Enum.map(&Integer.parse/1)
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.sum
  end
end

ExUnit.start()

defmodule Exercise1Test do
  use ExUnit.Case

  import Exercise1

  test "calibrate test data" do
    assert calibrate("""
                     +1
                     +1
                     +1
                     """) == 3

    assert calibrate("""
                     +1
                     +1
                     -2
                     """) == 0

    assert calibrate("""
                     -1
                     -2
                     -3
                     """) == -6
  end

  test "frequencies given for problem" do
		frequencies = File.read! "fixtures/day_01_frequencies.txt"

		assert calibrate(frequencies) == 490
	end
end
