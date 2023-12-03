import std/[strutils, sequtils, math]

type
  CubeSet = object
    red, green, blue: Natural
  GameSamples = object
    id: Natural
    samples: seq[CubeSet]

func parseInput(txt: string): seq[GameSamples] =
  for line in txt.strip.splitLines:
    var game: GameSamples
    let parts = line.split(":")

    game.id = parts[0].split(" ")[1].strip.parseInt
    for setText in parts[1].strip.split("; "):
      var cset: CubeSet
      for entry in setText.split(", "):
        let
          entryParts = entry.split(" ").mapIt(it.strip)
          num = entryParts[0].parseInt
        if entryParts[1] == "red":
          cset.red = num
        elif entryParts[1] == "green":
          cset.green = num
        elif entryParts[1] == "blue":
          cset.blue = num
        else:
          raise newException(ValueError, "unknown color " & parts[1])
        game.samples.add cset
    result.add game

func isGamePossible(game: GameSamples): bool =
  result = true
  for cset in game.samples:
    if cset.red > 12 or cset.green > 13 or cset.blue > 14 or
    ((cset.red + cset.green + cset.blue) > (12 + 13 + 14)):
      return false

let input = parseInput readFile("./input/day02_input.txt")

let pt1 = input.filter(isGamePossible).mapIt(it.id).sum
echo pt1

# Part 2

func getMinCubeSet(game: GameSamples): CubeSet =
  for cset in game.samples:
    if cset.red > result.red:
      result.red = cset.red
    if cset.green > result.green:
      result.green = cset.green
    if cset.blue > result.blue:
      result.blue = cset.blue

func power(cset: CubeSet): Natural =
  cset.red * cset.green * cset.blue

let pt2 = input.map(getMinCubeSet).map(power).sum
echo pt2
