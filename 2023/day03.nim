import std/[strutils, sequtils, math, enumerate]
import regex

let input = readFile("./input/day03_input.txt").strip.splitLines

func containsSymbol(s: string): bool =
  s.anyIt(it notin Digits and it != '.')

func hasAdjacentSymbol(input: seq[string], lineNum: int, bounds: Slice[int]): bool =
  let
    line = input[lineNum]
    xStart = max(0, bounds.a - 1)
    xEnd = min(line.high, bounds.b + 1)

  # check line above
  if lineNum > 0:
    if input[lineNum - 1][xStart .. xEnd].containsSymbol:
      return true

  # check line below
  if lineNum < input.high:
    if input[lineNum + 1][xStart .. xEnd].containsSymbol:
      return true

  # check left and right
  if line[xStart .. xEnd].containsSymbol:
    return true

func findPartNumbers(input: seq[string]): seq[Natural] =
  const patNumber = re2"\d+"
  for y, line in enumerate(input):
    for match in line.findAll(patNumber):
      if hasAdjacentSymbol(input, y, match.boundaries):
        result.add line[match.boundaries].parseInt

let pt1 = input.findPartNumbers.sum
echo pt1


# Part 2

type Coords = tuple[a, b: int]

func maxNorm(u, v: Coords): Natural = max(abs(u.a - v.a), abs(u.b - v.b))

func isGear(input: seq[string], loc: Coords): (bool, Natural) =
  if input[loc.a][loc.b] != '*':
    return

  var pnums: seq[int]

  var surLines = @[loc.a]
  if loc.a > 0: surLines.add loc.a - 1
  if loc.a < input.high: surLines.add loc.a + 1

  for lineNum in surLines:
    for match in input[lineNum].findAll(re2"\d+"):
      if maxNorm(loc, (lineNum, match.boundaries.a)) == 1 or
      maxNorm(loc, (lineNum, match.boundaries.b)) == 1:
        pnums.add input[lineNum][match.boundaries].parseInt

  if pnums.len == 2:
    result[0] = true
    result[1] = pnums[0] * pnums[1]

func findGears(input: seq[string]): seq[Natural] =
  let colHigh = input[0].high
  for lineNum in input.low .. input.high:
    for colNum in 0 .. colHigh:
      let (thisIsGear, ratio) = isGear(input, (lineNum, colNum))
      if thisIsGear:
        result.add ratio

let pt2 = input.findGears.sum
echo pt2
