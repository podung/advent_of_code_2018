defmodule Day7 do
  def order_steps(input) do
    input
    |> split_lines
    |> map_dependencies
    |> determine_order
  end

  defp split_lines(input), do: String.split(input, "\n", trim: true)

  defp map_dependencies(lines) do
    Enum.reduce(lines, %{}, fn line, dependency_map ->
      { dependency, step } = parse_step_dependency(line)

      dependency_map
      |> ensure_step_exists(dependency)
      |> ensure_step_exists(step)
      |> add_dependency(step, dependency)
    end)
  end

  defp parse_step_dependency("Step "
                             <> <<dependency::binary-size(1)>>
                             <> " must be finished before step "
                             <> <<step::binary-size(1)>>
                             <> " can begin.") do
    { dependency, step }
  end

  defp ensure_step_exists(dependency_map, step) do
    Map.put_new(dependency_map, step, MapSet.new)
  end

  defp add_dependency(dependency_map, step, dependency) do
    Map.update!(dependency_map, step, fn dependenciesForStep ->
      MapSet.put(dependenciesForStep, dependency)
    end)
  end

  defp determine_order(dependency_map), do: determine_order(dependency_map, [])

  defp determine_order(remaining, ordered_steps) when remaining == %{} do
    ordered_steps
    |> Enum.reverse
    |> Enum.join
  end

  defp determine_order(remaining, ordered_steps) do
    next_step = remaining
                |> Enum.filter(&available_steps/1)
                |> Enum.sort
                |> List.first
                |> elem(0)

    new_remaining =
    remaining
    |> Map.delete(next_step)
    |> Enum.map(fn { step, dependencies } ->
         { step, MapSet.delete(dependencies, next_step) }
       end)
    |> Map.new

    determine_order(new_remaining, [ next_step | ordered_steps ])
  end

  defp available_steps({ _step, dependencies }) do
    Enum.count(dependencies) == 0
  end
end

ExUnit.start()

defmodule Day7Test do
  use ExUnit.Case

  import Day7

  describe "order_steps" do
    test "example data" do
      assert order_steps("""
        Step C must be finished before step A can begin.
        Step C must be finished before step F can begin.
        Step A must be finished before step B can begin.
        Step A must be finished before step D can begin.
        Step B must be finished before step E can begin.
        Step D must be finished before step E can begin.
        Step F must be finished before step E can begin.
        """) == "CABDFE"
    end

    test "test data for problem" do
      input = File.read! "fixtures/day_07_steps.txt"

      assert order_steps(input) == "BGKDMJCNEQRSTUZWHYLPAFIVXO"
    end
  end
end
