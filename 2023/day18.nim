import std/strutils

import std/sequtils

import std/strscans

import std/sets

import utils

type
  Color = int

  DigPlanInstruction = object
    dir: Compass
    count: int
    color: Color

  DigPlan = seq[DigPlanInstruction]

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

func shoelace(segs: seq[LineSegment]): int =
  for i, line in segs.pairs:
    result.inc line.a.x * line.b.y - line.b.x * line.a.y
  result = abs(result) div 2

func edgeArea(segs: seq[LineSegment]): int =
  let numVertices = segs.len
  assert (numVertices - 4) mod 2 == 0

  let
    numInside = (numVertices - 4) div 2
    numOutside = numInside + 4
  assert numInside + numOutside == numVertices

  for line in segs:
    result.inc manhattan(line.a, line.b) - 1

  assert result mod 2 == 0
  result = result div 2

  assert (numInside + numOutside * 3) mod 4 == 0
  result.inc (numInside + numOutside * 3) div 4

func lagoonArea(plan: DigPlan): int =
  let poly = plan.toLines
  result = shoelace(poly) + edgeArea(poly)

let pt1 = lagoonArea(input)
echo pt1

# Part 2

func convertP2(ins: DigPlanInstruction): DigPlanInstruction =
  result.count = ins.color shr 4

  let dirCode = ins.color and 0x00000F
  doAssert dirCode <= 3
  result.dir = [East, South, West, North][dirCode]

let plan2 = input.map(convertP2)
let pt2 = lagoonArea plan2

echo pt2
