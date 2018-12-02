defmodule Exercise1 do
  defmodule Accumulator do
    defstruct current: 0, seen: MapSet.new([0]), calibrated: false
  end

  def calibrate_simple(readings) when is_binary readings do
    readings
    |> parse
    |> Enum.sum
  end

  def calibrate(readings) when is_binary readings do
    readings
    |> parse
    |> do_calibrate
  end

  defp parse(readings) do
    readings
    |> String.split("\n", trim: true)
    |> Enum.map(&Integer.parse/1)
    |> Enum.map(&(elem(&1, 0)))
  end

  defp do_calibrate(_, acc \\ %Accumulator{})

  defp do_calibrate(_, acc = %Accumulator{ calibrated: true }) do
    acc.current
  end

  defp do_calibrate(list = [_|_], acc) do
    result = Enum.reduce_while(list, acc, &process/2)

    do_calibrate(list, result)
  end

  defp process(adjustment, %Accumulator{} = acc) do
    current = adjustment + acc.current

    if (MapSet.member?(acc.seen, current)) do
      { :halt, %{ acc | current: current, calibrated: true } }

    else
      { :cont, %{ acc | current: current,
                        seen: MapSet.put(acc.seen, current) } }
    end
  end
end

ExUnit.start()

defmodule Exercise1Test do
  use ExUnit.Case

  import Exercise1

  describe "calibrate_simple" do
    test "calibrate_simple scenarios" do
      assert calibrate_simple("""
                              +1
                              +1
                              +1
                              """) == 3

      assert calibrate_simple("""
                              +1
                              +1
                              -2
                              """) == 0

      assert calibrate_simple("""
                              -1
                              -2
                              -3
                              """) == -6
    end

    test "frequencies given for problem" do
      frequencies = File.read! "fixtures/day_01_frequencies.txt"

      assert calibrate_simple(frequencies) == 490
    end
  end

  describe "calibrate" do
    test "calibrate scenarios" do
      assert calibrate("""
                       +1
                       -1
                       """) == 0

      assert calibrate("""
                       +3
                       +3
                       +4
                       -2
                       -4
                       """) == 10

      assert calibrate("""
                       -6
                       +3
                       +8
                       +5
                       -6
                       """) == 5

      assert calibrate("""
                       +7
                       +7
                       -2
                       -7
                       -4
                       """) == 14
    end

    test "frequencies given for problem" do
      frequencies = File.read! "fixtures/day_01_frequencies.txt"

      assert calibrate(frequencies) == 70357
    end
  end
end
