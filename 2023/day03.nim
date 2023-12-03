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


