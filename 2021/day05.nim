import std/strutils
import std/sequtils
import std/tables
import utils

type LineSegment = object
  p1: Vector
  p2: Vector

func parseInputLine(s: string): LineSegment =
  let ints = s.getInts
  assert ints.len == 4

  result.p1 = (ints[0], ints[1])
  result.p2 = (ints[2], ints[3])

let input = readFile("./input/day05_input.txt").strip().splitLines().map(parseInputLine)
# let input = """
# 0,9 -> 5,9
# 8,0 -> 0,8
# 9,4 -> 3,4
# 2,2 -> 2,1
# 7,0 -> 7,4
# 6,4 -> 2,0
# 0,9 -> 2,9
# 3,4 -> 1,4
# 0,0 -> 8,8
# 5,5 -> 8,2
# """.strip().splitLines().map(parseInputLine)

func isHorzOrVert(ls: LineSegment): bool =
  (ls.p1.x == ls.p2.x) or (ls.p1.y == ls.p2.y)

func countOverlapsHorzVert(lines: seq[LineSegment]): int =
  var grid = newCountTable[Vector]()
  for ls in lines:
    if not isHorzOrVert(ls): continue

    let unit = (ls.p2 - ls.p1) / manhattan(ls.p1, ls.p2)
    assert unit == (0, 1) or unit == (1, 0) or unit == (-1, 0) or unit == (0, -1)

    grid.inc(ls.p1)
    grid.inc(ls.p2)
    var cur = ls.p1 + unit
    while cur != ls.p2:
      grid.inc(cur)
      cur.inc(unit)

  for (pt, count) in grid.pairs:
    if count > 1: result.inc

let pt1Overlaps = countOverlapsHorzVert(input)
echo pt1Overlaps
doAssert pt1Overlaps == 8622
