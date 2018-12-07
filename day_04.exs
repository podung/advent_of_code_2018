defmodule Day4 do

  def sleepy_guard(input) do
    input
    |> process_sleep_records
    |> sleepiest
    |> calc
  end

  def sleepiest_minute_guard(input) do
    input
    |> process_sleep_records
    |> calculate_sleepiest_minute_per_guard
    |> sleepiest_on_single_minute
    |> multiply
  end

  defp process_sleep_records(input) do
    input
    |> split_lines
    |> sort_by_date
    |> Enum.map(&strip_date_and_hour_part/1)
    |> Enum.map(&parse_minutes_and_action/1)
    |> Enum.chunk_while({}, &process_sleep_records/2, fn acc ->
         { :cont, acc, [] }
       end)
    |> Enum.reduce(%{}, &countMinutesPerGuard/2)
  end

  defp split_lines(input), do: String.split(input, "\n", trim: true)

  defp sort_by_date(entries) do
    Enum.sort(entries)
  end

  defp strip_date_and_hour_part(<<_date_and_hour_part::binary-size(15)>>
                                <> rest), do: rest

  defp parse_minutes_and_action(<<minutes::binary-size(2)>>
                                <> "] "
                                <> action), do: { String.to_integer(minutes), action }

  defp process_sleep_records({ _minute, "Guard #" <> rest }, {}) do
    { guard, _ } = Integer.parse(rest)
    { :cont, { guard, [] } }
  end

  defp process_sleep_records({ _minute, "Guard #" <> rest }, prev_accumulator) do
    { guard, _ } = Integer.parse(rest)
    { :cont, prev_accumulator, { guard, [] } }
  end

  defp process_sleep_records({ minute_fell_asleep, "falls asleep"}, { guard, minutes_map }) do
    { :cont, { guard, minutes_map, minute_fell_asleep} }
  end

  defp process_sleep_records({ minute_awoke, _action}, { guard, minutes_map, minute_fell_asleep }) do
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

  defp total_minutes_asleep({ _, minutesMap } ) do
    minutesMap
    |> Map.values
    |> Enum.sum
  end

  defp sleepiest(guards), do: Enum.max_by(guards, &total_minutes_asleep/1)

  defp tiredest_minute(minutes), do: minutes |> Enum.max_by(fn {_,cnt} -> cnt end, fn -> { 0, 0 } end)

  defp tiredest_minute_value({ minute, _count }), do: minute
  defp tiredest_minute_count({ _minute, count }), do: count

  defp calc({ guard_number, minutes }) do
    minute = minutes |> tiredest_minute |> tiredest_minute_value
    guard_number * minute
  end

  defp calculate_sleepiest_minute_per_guard(guards) do
    Enum.map(guards, fn { guard, minutes } ->
      tiredest = tiredest_minute(minutes)
      { guard, tiredest_minute_value(tiredest), tiredest_minute_count(tiredest) }
    end)
  end

  defp sleepiest_on_single_minute(guards), do: Enum.max_by(guards, fn { _guard, _minute, count } -> count end)

  defp multiply({ guard, minute, _count }), do: guard * minute
end

ExUnit.start()

defmodule Day4Test do
  use ExUnit.Case

  import Day4

  describe "sleepiest" do
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
                          """) == 240
    end

    test "overlapping for given for problem" do
      sleep_schedule = File.read! "fixtures/day_04_sleepschedules.txt"

      assert sleepy_guard(sleep_schedule) == 72925
    end
  end

  describe "sleepiest_minute_guard" do
    test "sleepiest minute example scenarios" do
      assert sleepiest_minute_guard("""
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
                          """) == 4455
    end

    test "sleepiest minute for given for problem" do
      sleep_schedule = File.read! "fixtures/day_04_sleepschedules.txt"

      assert sleepiest_minute_guard(sleep_schedule) == 49137
    end
  end
end
