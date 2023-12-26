import std/strutils

import std/algorithm

import std/strscans

import std/sets

import std/options

import utils

type
  Color = int

  DigPlanInstruction = object
    dir: Compass
    count: int
    color: Color

  DigPlan = seq[DigPlanInstruction]

  LineSegment = tuple[a, b: Vector]

func parseInput(txt: string): DigPlan =
  for line in txt.strip.splitLines:
    var
      dirChar: char
      ins: DigPlanInstruction
    doAssert scanf(line, "$c $i (#$h)", dirChar, ins.count, ins.color)

    doAssert dirChar in {'U', 'D', 'L', 'R'}
    ins.dir =
      case dirChar
      of 'U':
        North
      of 'D':
        South
      of 'L':
        West
      of 'R':
        East
      else:
        North
    result.add ins

#let input = readFile("input/day18_example.txt").parseInput
let input = readFile("input/day18_input.txt").parseInput

func show(lag: HashSet[Vector]): string =
  let corners = lag.getBoundingBox
  for y in countDown(corners[1].y, corners[0].y):
    var row: string
    for x in corners[0].x..corners[1].x:
      let c =
        if (x, y) in lag:
          '#'
        else:
          '.'
      row.add c
    result.add row
    result.add '\n'

func toLines(plan: DigPlan): seq[LineSegment] =
  var cur: Vector = (0, 0)
  for ins in plan:
    let next = cur + (ins.dir.toVector * ins.count)
    result.add (cur, next)
    cur = next
  assert cur == (0, 0)

func isHorizontal(line: LineSegment): bool =
  line.a.y == line.b.y

func isVertical(line: LineSegment): bool =
  line.a.x == line.b.x

func rayIntersect(line: LineSegment; y: int): Option[int] =
  ## Intersection of horizontal ray at height y with vertical line
  let yrange = min(line.a.y, line.b.y)..<max(line.a.y, line.b.y)
  if line.isVertical and y in yrange:
    return some(line.a.x)

func rayIntersect(lines: openArray[LineSegment]; y: int): seq[int] =
  for ln in lines:
    let xi = ln.rayIntersect(y)
    if xi.isSome:
      result.add xi.get
  sort result

func getBoundingBox(lines: openArray[LineSegment]): (Vector, Vector) =
  var
    upperLeft: Vector = (int.high, int.high)
    lowerRight: Vector = (int.low, int.low)
  for ln in lines:
    for v in [ln.a, ln.b]:
      if v.x < upperLeft.x:
        upperLeft.x = v.x
      if v.y < upperLeft.y:
        upperLeft.y = v.y
      if v.x > lowerRight.x:
        lowerRight.x = v.x
      if v.y > lowerRight.y:
        lowerRight.y = v.y
  result = (upperLeft, lowerRight)

func rasterizeEdges(lines: openArray[LineSegment]): HashSet[Vector] =
  for ln in lines:
    if ln.isVertical:
      let x = ln.a.x
      for y in min(ln.a.y, ln.b.y)..max(ln.a.y, ln.b.y):
        result.incl (x, y)
    elif ln.isHorizontal:
      let y = ln.a.y
      for x in min(ln.a.x, ln.b.x)..max(ln.a.x, ln.b.x):
        result.incl (x, y)

func rasterize(plan: DigPlan): HashSet[Vector] =
  let
    lines = plan.toLines
    corners = lines.getBoundingBox

  result = lines.rasterizeEdges

  for y in corners[0].y..corners[1].y:
    let intersections = lines.rayIntersect(y)
    assert intersections.len mod 2 == 0

    for i in countup(intersections.low, intersections.high, 2):
      for x in intersections[i]..intersections[i + 1]:
        result.incl (x, y)

writeFile("lagoon.txt", input.toLines.rasterizeEdges.show)

let pt1 = input.rasterize.card
echo pt1
