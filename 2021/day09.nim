import std/tables
import std/sequtils
import std/strutils
import std/algorithm
import utils

#let input = """
#2199943210
#3987894921
#9856789892
#8767896789
#9899965678
#"""
let input = readFile("./input/day09_input.txt")

type SeaFloorMap = seq[seq[int]]

func parseInput(s: string): SeaFloorMap =
  for line in s.strip.splitLines:
    result.add line.mapIt(parseInt($it))

func `[]`(g: SeaFloorMap, v: Vector): int =
  g[v.y][v.x]

iterator tilePairs(g: SeaFloorMap): (Vector, int) =
  for (i, row) in g.pairs:
    for (j, elem) in row.pairs:
      yield ((j, i), elem)

iterator adjacent(g: SeaFloorMap, at: Vector): Vector =
  if at.x > 0:
    yield (at.x - 1, at.y)
  if at.x < g[at.y].high:
    yield (at.x + 1, at.y)
  if at.y > 0:
    yield (at.x, at.y - 1)
  if at.y < g.high:
    yield (at.x, at.y + 1)

func isLowPoint(g: SeaFloorMap, at: Vector): bool =
  for pt in g.adjacent(at):
    if g[pt] <= g[at]:
      return false
  return true

func sumRiskLevels(g: SeaFloorMap): int =
  for (v, height) in g.tilePairs:
    if g.isLowPoint(v):
      result.inc (height + 1)

let
  fmap = input.parseInput
  pt1 = fmap.sumRiskLevels()

echo pt1

# Part 2

func findBasin(g: SeaFloorMap, at: Vector): Vector =
  result = at
  while not g.isLowPoint(result):
    var
      next: Vector
      minAdjHeight: int = int.high
    for neighbor in g.adjacent(result):
      if g[neighbor] < g[result] and g[neighbor] < minAdjHeight:
        next = neighbor
        minAdjHeight = g[neighbor]
    assert minAdjHeight < int.high
    result = next

func CountBasinSizes(g: SeaFloorMap): CountTable[Vector] =
  for (v, height) in g.tilePairs:
    if height == 9:
      continue
    result.inc g.findBasin(v)

let
  basinSizes = fmap.CountBasinSizes
  pt2 = toSeq(basinSizes.values).sorted[^3 .. ^1].foldl(a * b)

echo pt2
