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
  result.map = initTable[Vector, CaveTile](100_000)

  for line in text.strip.splitLines:
    let vecs = line.split(" -> ").map(parseVector)
    assert vecs.len > 1
    for vecIdx in 1 .. vecs.high:
      for pt in iterLine(vecs[vecIdx - 1], vecs[vecIdx]):
        result.map[pt] = Rock
        if pt.y > result.lowPoint:
          result.lowPoint = pt.y

let input = readFile("./input/day14_input.txt").parseInput
const sandSource: Vector = (500, 0)

func part1(inp: Input): int =
  var map = inp.map
  while true:
    var atRest = false
    var sandUnit: Vector = sandSource
    while not atRest:
      if sandUnit.y > inp.lowPoint:
        return
      atRest = true
      for candidate in [(0, 1), (-1, 1), (1, 1)]:
        if (sandUnit + candidate) notin map:
          sandUnit.inc candidate
          atRest = false
          break
      if atRest:
        map[sandUnit] = Sand
        result.inc

func part2(inp: Input): int =
  var map = inp.map
  let floor = inp.lowPoint + 2

  while true:
    var atRest = false
    var sandUnit: Vector = sandSource
    while not atRest:
      atRest = true
      for dir in [(0, 1), (-1, 1), (1, 1)]:
        let candidate = sandUnit + dir
        if (candidate.y < floor) and (candidate notin map):
          sandUnit = candidate
          atRest = false
          break
      if atRest:
        map[sandUnit] = Sand
        result.inc
        if sandUnit == sandSource:
          return

echo part1(input)
echo part2(input)
