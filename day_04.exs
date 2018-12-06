defmodule Day4 do

  def tap(input, func) do
    func.(input)
    input
  end

  def sleepy_guard(input) do
    input
    |> split_lines
    |> sort_by_date
    |> tap(&(IO.inspect &1))
    |> Enum.map(&strip_date_and_hour_part/1)
    |> Enum.map(&parse_minutes_and_action/1)
    |> tap(&(IO.inspect &1))
    |> Enum.chunk_while({}, &process_sleep_records/2, fn acc ->
         IO.puts "in final thing"
         IO.inspect(acc)
         # TODO: what the heck does this thing do???? - how does it use final emtpy list???
         { :cont, acc, [] }
       end)
    |> Enum.reduce(%{}, &countMinutesPerGuard/2)
  end

  defp split_lines(input), do: String.split(input, "\n", trim: true)

  defp sort_by_date(entries) do
    Enum.sort(entries)
  end

  defp strip_date_and_hour_part(<<date_and_hour_part::binary-size(15)>>
                                <> rest), do: rest

  defp parse_minutes_and_action(<<minutes::binary-size(2)>>
                                <> "] "
                                <> action), do: { String.to_integer(minutes), action }

  defp process_sleep_records({ minute, "Guard #" <> rest }, acc = {}) do
    { guard, _ } = Integer.parse(rest)
    { :cont, { guard, [] } }
  end

  defp process_sleep_records({ minute, "Guard #" <> rest }, prev_accumulator) do
    { guard, _ } = Integer.parse(rest)
    { :cont, prev_accumulator, { guard, [] } }
  end

  defp process_sleep_records({ minute_fell_asleep, "falls asleep"}, { guard, minutes_map }) do
    { :cont, { guard, minutes_map, minute_fell_asleep} }
  end

  defp process_sleep_records({ minute_awoke, action}, { guard, minutes_map, minute_fell_asleep }) do
    nap_time = Enum.to_list(minute_fell_asleep..minute_awoke - 1)

    { :cont, { guard, List.flatten([ nap_time | minutes_map ]) } }
  end

  defp countMinutesPerGuard({ guard, minutes }, guardMap) do
    minutesMapFor = Map.put_new(guardMap, guard, %{})
    mapForGuard = minutesMapFor[guard]


    newMap = Enum.reduce(minutes, mapForGuard, fn minute, acc ->
               Map.update(acc, minute, 1, &(&1 + 1))
             end)

    Map.put(minutesMapFor, guard, newMap)
  end
end

ExUnit.start()

defmodule Day4Test do
  use ExUnit.Case

  import Day4

  describe "find_hours" do
    test "overlap example scenarios" do
      assert sleepy_guard("""
                          [1518-11-01 00:30] falls asleep
                          [1518-11-01 00:55] wakes up
                          [1518-11-01 00:00] Guard #10 begins shift
                          [1518-11-01 00:25] wakes up
                          [1518-11-05 00:55] wakes up
                          [1518-11-01 23:58] Guard #99 begins shift
                          [1518-11-02 00:40] falls asleep
                          [1518-11-02 00:50] wakes up
                          [1518-11-03 00:05] Guard #10 begins shift
                          [1518-11-04 00:02] Guard #99 begins shift
                          [1518-11-04 00:46] wakes up
                          [1518-11-05 00:03] Guard #99 begins shift
                          [1518-11-05 00:45] falls asleep
                          [1518-11-04 00:36] falls asleep
                          [1518-11-01 00:05] falls asleep
                          [1518-11-03 00:24] falls asleep
                          [1518-11-03 00:29] wakes up
                          """) == 5
    end

    #test "overlapping for given for problem" do
      #sleep_schedule = File.read! "fixtures/day_04_sleepschedules.txt"

      #assert sleepy_guard(sleep_schedule) == 113716
    #end
  end
end
