import std/strutils
import std/sequtils
import std/tables
import ./utils

type
  CaveTile = enum Rock, Sand

  CaveMap = Table[Vector, CaveTile]

  Input = object
    map: CaveMap
    lowPoint: int

func sortedSlice(a, b: int): Slice[int] =
  if b >= a:
    a .. b
  else:
    b .. a

iterator iterLine(a, b: Vector): Vector =
  if a.x == b.x:
    for j in sortedSlice(a.y, b.y):
      yield (a.x, j)
  elif a.y == b.y:
    for i in sortedSlice(a.x, b.x):
      yield (i, a.y)
  else:
    doAssert false # invalid line

func parseInput(text: string): Input =
  result.lowPoint = int.low

  for line in text.strip.splitLines:
    let vecs = line.split(" -> ").map(parseVector)
    assert vecs.len > 1
    for vecIdx in 1 .. vecs.high:
      for pt in iterLine(vecs[vecIdx - 1], vecs[vecIdx]):
        result.map[pt] = Rock
        if pt.y > result.lowPoint:
          result.lowPoint = pt.y

let input = readFile("./input/day14_input.txt").parseInput
#let input = """
#498,4 -> 498,6 -> 496,6
#503,4 -> 502,4 -> 502,9 -> 494,9
#""".parseInput


func part1(inp: Input): int =
  var
    map = inp.map
    abyssFlag = false

  while not abyssFlag:
    var atRest = false
    var sandUnit: Vector = (500, 0)
    while not (atRest or abyssFlag):
      if sandUnit.y > inp.lowPoint:
        abyssFlag = true
        break
      atRest = true
      for candidate in [(0, 1), (-1, 1), (1, 1)]:
        if (sandUnit + candidate) notin map:
          sandUnit.inc candidate
          atRest = false
          break
      if atRest:
        map[sandUnit] = Sand
        result.inc

echo part1(input)
