defmodule Day3Part1 do

  def overlapping(input) do
    input
    |> split_lines
    |> Enum.flat_map(&parse_claim/1)
    |> Enum.reduce({ MapSet.new, MapSet.new }, &identify_repeated/2)
    |> elem(1)
    |> MapSet.size
  end

  defp split_lines(input), do: String.split(input, "\n", trim: true)

  defp parse_claim("#" <> <<claim_id::bytes-size(1)>>
                       <> " @ "
                       <> << x::bytes-size(1) >>
                       <> ","
                       <> << y::bytes-size(1) >>
                       <> ": "
                       <> << w::bytes-size(1) >>
                       <> "x"
                       <> << h::bytes-size(1) >>) do

    x = String.to_integer(x)
    y = String.to_integer(y)
    w = String.to_integer(w)
    h = String.to_integer(h)

    for xCoord <- (x+1..x+w), yCoord <- y+1..y+h, do: { xCoord, yCoord }
  end

  defp identify_repeated(coord, { seen, repeated }) do
    if MapSet.member?(seen, coord) do
      { MapSet.put(seen, coord), MapSet.put(repeated, coord) }
    else
      { MapSet.put(seen, coord), repeated }
    end
  end
end

ExUnit.start()

defmodule Day3Test do
  use ExUnit.Case

  import Day3Part1

  describe "overlapping" do
    test "overlap example scenarios" do
      assert overlapping("""
                         #1 @ 1,3: 4x4
                         #2 @ 3,1: 4x4
                         #3 @ 5,5: 2x2
                         """) == 4
    end

    #test "overlapping for given for problem" do
      #claims = File.read! "fixtures/day_03_claims.txt"

      #assert overlapping(claims) == 4
    #end
  end
end
