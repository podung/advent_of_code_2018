defmodule Day6 do
  def largest_area(input) do
    input
    |> parse_coordinates
    |> mark_boundaries
    |> calculate_closest_coordinate_per_grid_point
    |> sum_areas_per_coordinate
    |> filter_to_non_infinite_areas
    |> get_max
  end

  defp split_lines(input), do: String.split(input, "\n", trim: true)

  defp parse_coordinates(input) do
    input
    |> split_lines
    |> Enum.map(&parse_coordinate/1)
  end

  defp parse_coordinate(line) do
    line
    |> String.split(", ")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple
  end

  defp mark_boundaries(coordinates) do
    boundaries = Enum.reduce(coordinates, %{}, fn { x, y }, acc ->
      acc
      |> Map.update(:top,    y, &min(&1, y))
      |> Map.update(:left,   x, &min(&1, x))
      |> Map.update(:bottom, y, &max(&1, y))
      |> Map.update(:right,  x, &max(&1, x))
    end)

    { coordinates, boundaries }
  end

  defp calculate_closest_coordinate_per_grid_point({ coordinates, boundaries }) do
    for x <- (boundaries.left..boundaries.right),
        y <- (boundaries.top..boundaries.bottom) do
       distances = Enum.reduce(coordinates, %{}, fn coord, map ->
                     Map.put(map, coord, distance({ x, y }, coord))
                   end)

       # Add distances.total_to_all
       { closest(distances), point_on_boundary(x, y, boundaries) }
    end
  end

  defp distance({ x1, y1 }, { x2, y2 }), do: abs(x1 - x2) + abs(y1 - y2)

  defp point_on_boundary(x, y, %{ top: top, left: left, bottom: bottom, right: right }) do
    ( x == left || x == right ) || ( y == top || y == bottom )
  end

  defp sum_areas_per_coordinate(grid) do
    grid
    |> Enum.reduce(%{}, fn { coord, on_border }, acc ->
        Map.update(acc, coord, { 1, on_border },
          fn { existing_count, existing_on_border } ->
            { existing_count + 1, on_border || existing_on_border }
          end)
       end)
    |> Map.values
  end

  defp filter_to_non_infinite_areas(areas) do
    Enum.filter(areas, fn
      { _count, infinite } -> !infinite
    end)
  end

  defp get_max(areas) do
    areas
    |> Enum.map(fn { count, _ } -> count end)
    |> Enum.max
  end

  defp closest(distances) do
    distances
    |> Enum.sort_by(fn { _coord, distance } -> distance end)
    |> closest_or_tie
  end

  defp closest_or_tie([ { _, dist }, { _, dist } | _tail ]), do: :tie
  defp closest_or_tie([ { closest, _dist } | _tail ]), do: closest
end

ExUnit.start()

defmodule Day6Test do
  use ExUnit.Case

  import Day6

  describe "trigger" do
    test "largest_area" do
      assert largest_area("""
        1, 1
        1, 6
        8, 3
        3, 4
        5, 5
        8, 9
        """) == 17
    end

    #test "test data for problem" do
      #input = File.read! "fixtures/day_06_coordinates.txt"

      #assert largest_area(input) == 3569
    #end
  end
end
