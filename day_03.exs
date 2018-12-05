defmodule Day3 do

  def overlapping(input) do
    input
    |> split_lines
    |> Enum.map(&parse_claim/1)
    |> Enum.map_reduce({ MapSet.new, MapSet.new }, &identify_repeated/2)
    |> combine_results
    |> get_repeated
    |> MapSet.size
  end

  def free_and_clear_claim_id(input) do
    input
    |> split_lines
    |> Enum.map(&parse_claim/1)
    |> Enum.map_reduce({ MapSet.new, MapSet.new }, &identify_repeated/2)
    |> combine_results
    |> get_id_of_clear_claim
  end


  defp split_lines(input), do: String.split(input, "\n", trim: true)

  defp parse_claim("#" <> rest) do
   # TODO: replace this with regex or bitstring pattern matching
   [ claim_id, rest ] = String.split(rest, " @ ")
   [ x,        rest ] = String.split(rest, ",")
   [ y,        rest ] = String.split(rest, ": ")
   [ w,           h ] = String.split(rest, "x")

    x = String.to_integer(x)
    y = String.to_integer(y)
    w = String.to_integer(w)
    h = String.to_integer(h)

    coords = for xCoord <- (x+1..x+w),
                 yCoord <- y+1..y+h, into: MapSet.new(),
                                     do: { xCoord, yCoord }

    { claim_id, coords }
  end

  defp identify_repeated(claim = { _, coords }, { seen, repeated }) do
    overlapping = MapSet.intersection(seen, coords)

    if MapSet.size(overlapping) > 0 do
      { claim, { MapSet.union(seen, coords), MapSet.union(repeated, overlapping) } }
    else
      { claim, { MapSet.union(seen, coords), repeated } }
    end
  end

  defp combine_results({ claims, { seen, repeated }}), do: { claims, seen, repeated }

  defp get_repeated({ _, _, repeated }), do: repeated

  defp get_id_of_clear_claim({ claims, _, repeated }) do
    claims
    |> Enum.find(fn { _, claims } -> MapSet.disjoint?(claims, repeated) end)
    |> elem(0)
  end
end

ExUnit.start()

defmodule Day3Test do
  use ExUnit.Case

  import Day3

  describe "overlapping" do
    test "overlap example scenarios" do
      assert overlapping("""
                         #1 @ 1,3: 4x4
                         #2 @ 3,1: 4x4
                         #3 @ 5,5: 2x2
                         """) == 4
    end

    test "overlapping for given for problem" do
      claims = File.read! "fixtures/day_03_claims.txt"

      assert overlapping(claims) == 113716
    end
  end

  describe "free_and_clear_claim_id" do
    test "example scenarios" do
      assert free_and_clear_claim_id("""
                                     #1 @ 1,3: 4x4
                                     #2 @ 3,1: 4x4
                                     #3 @ 5,5: 2x2
                                     """) == "3"
    end

    test "solution for given for problem" do
      claims = File.read! "fixtures/day_03_claims.txt"

      assert free_and_clear_claim_id(claims) == "742"
    end
  end
end
