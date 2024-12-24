import std/strutils
import std/sequtils
import std/enumerate
import std/tables
import std/sets
import std/math
import utils

type Input = object
  antennas: Table[char, seq[Vector]]
  extents: Vector

func parseInput(s: string): Input =
  for (y, row) in enumerate(ritems(s.strip.splitLines)):
    for (x, c) in row.pairs:
      result.extents.y = y
      result.extents.x = x
      if c != '.':
        result.antennas.mgetOrPut(c, @[]).add (x, y)

let input = readFile("./input/day08_input.txt").parseInput

func isInExtents(input: Input, v: Vector): bool =
  v.x >= 0 and v.y >= 0 and v.x <= input.extents.x and v.y <= input.extents.y

func p1(input: Input): int =
  var antinodes: HashSet[Vector]
  for (freq, antennas) in input.antennas.pairs:
    for antennaPair in antennas.combinations(2):
      let
        (a, b) = (antennaPair[0], antennaPair[1])
        d = b - a # direction vector from a to b

        # antinodes
        n1 = b + d
        n2 = a - d

      for an in [n1, n2]:
        if isInExtents(input, an):
          antinodes.incl an

  result = antinodes.card

echo p1(input)

func vectorGcd(v: Vector): Vector = v / gcd(v.x, v.y)

func p2(input: Input): int =
  var antinodes: HashSet[Vector]
  for (freq, antennas) in input.antennas.pairs:
    for antennaPair in antennas.combinations(2):
      let
        (a, b) = (antennaPair[0], antennaPair[1])
        d = vectorGcd(b - a) # unit direction vector from a to b

      for i in 0 .. 1000000:
        let
          an1 = b + (i * d)
          an2 = b - (i * d)
          an1IsInside = isInExtents(input, an1)
          an2IsInside = isInExtents(input, an2)

        if an1IsInside: antinodes.incl an1
        if an2IsInside: antinodes.incl an2
        if not (an1IsInside or an2IsInside): break

  result = antinodes.card

echo p2(input)
