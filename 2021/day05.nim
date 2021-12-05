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

func sgn(x: int): int =
  if x == 0: 0
  elif x > 0: 1
  else: -1

func unit(ls: LineSegment): Vector =
  let v = ls.p2 - ls.p1
  result = (v.x.sgn, v.y.sgn)

func countOverlaps(lines: seq[LineSegment], diagonals: bool): int =
  var grid = newCountTable[Vector]()
  for ls in lines:
    if (not diagonals) and (not isHorzOrVert(ls)): continue

    let lsUnit = ls.unit

    var cur = ls.p1
    grid.inc(ls.p2)
    while cur != ls.p2:
      grid.inc(cur)
      cur.inc(lsUnit)

  for (pt, count) in grid.pairs:
    if count > 1: result.inc

let pt1Overlaps = countOverlaps(input, false)
echo pt1Overlaps
doAssert pt1Overlaps == 8622

let pt2Overlaps = countOverlaps(input, true)
echo pt2Overlaps
doAssert pt2Overlaps == 22037
