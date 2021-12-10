
import std/sequtils
import std/strutils
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

func `[]`(g: SeaFloorMap, v: Vector): int =
  g[v.y][v.x]

iterator tilePairs(g: SeaFloorMap): (Vector, int) =
  for (i, row) in g.pairs:
    for (j, elem) in row.pairs:
      yield ((j, i), elem)

iterator adjacent(g: SeaFloorMap, at: Vector): int =
  if at.x > 0:
    yield g[at.y][at.x - 1]
  if at.x < g[at.y].high:
    yield g[at.y][at.x + 1]
  if at.y > 0:
    yield g[at.y - 1][at.x]
  if at.y < g.high:
    yield g[at.y + 1][at.x]

func isLowPoint(g: SeaFloorMap, at: Vector): bool =
  for adjHeight in g.adjacent(at):
    if adjHeight <= g[at]:
      return false
  return true

func parseInput(s: string): SeaFloorMap =
  for line in s.strip.splitLines:
    result.add line.mapIt(parseInt($it))

func sumRiskLevels(g: SeaFloorMap): int =
  for (v, height) in g.tilePairs:
    if g.isLowPoint(v):
      result.inc (height + 1)

let
  fmap = input.parseInput
  pt1 = fmap.sumRiskLevels()

echo pt1


