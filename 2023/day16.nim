import std/strutils

import std/sequtils

import std/sets

import utils

type
  Contraption = SeqGrid[char]

  Beam = object
    loc, dir: Vector

func parseInput(txt: string): Contraption =
  for line in txt.strip.splitLines:
    result.add toSeq(line)

#let input = readFile("input/day16_example.txt").parseInput
let input = readFile("input/day16_input.txt").parseInput

func next(b: Beam): Beam =
  Beam(loc: (b.loc + b.dir), dir: b.dir)

func cw(b: Beam): Beam =
  Beam(loc: b.loc, dir: b.dir.cw2)

func ccw(b: Beam): Beam =
  Beam(loc: b.loc, dir: b.dir.ccw2)

func isHorizontal(b: Beam): bool =
  b.dir.isHorizontal

func isVertical(b: Beam): bool =
  b.dir.isVertical

iterator splitH(b: Beam): Beam =
  if b.isHorizontal:
    yield b.next
  else:
    yield b.cw.next
    yield b.ccw.next

iterator splitV(b: Beam): Beam =
  if b.isVertical:
    yield b.next
  else:
    yield b.cw.next
    yield b.ccw.next

func energize(cont: Contraption; start: Beam): HashSet[Vector] =
  var
    stack: seq[Beam]
    seen: HashSet[Beam]

  stack.add start
  while stack.len > 0:
    let beam = stack.pop

    if not cont.isInside(beam.loc):
      continue

    if beam in seen:
      continue
    else:
      seen.incl beam

    result.incl beam.loc
    case cont[beam.loc]
    of '.':
      stack.add beam.next
    of '-':
      for n in beam.splitH:
        stack.add n
    of '|':
      for n in beam.splitV:
        stack.add n
    of '/':
      if beam.isHorizontal:
        stack.add beam.ccw.next
      else:
        stack.add beam.cw.next
    of '\\':
      if beam.isVertical:
        stack.add beam.ccw.next
      else:
        stack.add beam.cw.next
    else:
      assert false

proc showEnergized(cont: Contraption; enset: HashSet[Vector]) =
  for irow in 0..cont.nrows:
    for icol in 0..cont.ncolumns:
      if (icol, irow) in enset:
        stdout.write '#'
      else:
        stdout.write '.'
    stdout.write '\n'

let energized = input.energize(start = Beam(loc: (0, 0), dir: (1, 0)))
#input.showEnergized(energized)
echo energized.card

#let pt1 = input.energize.card
#echo pt1

# Part 2

iterator allStartingConfigs(cont: Contraption): Beam =
  let
    yhigh = cont.nrows - 1
    xhigh = cont.ncolumns - 1

  # Top and bottom edged
  for x in 0..<cont.ncolumns:
    yield Beam(loc: (x, 0), dir: (0, 1))
    yield Beam(loc: (x, yhigh), dir: (0, -1))

  # Left and right edges
  for y in 0..<cont.nrows:
    yield Beam(loc: (0, y), dir: (1, 0))
    yield Beam(loc: (xhigh, y), dir: (-1, 0))

let pt2 =
  block:
    var m = 0
    for cfg in input.allStartingConfigs:
      let enerCount = input.energize(cfg).card
      if enerCount > m:
        m = enerCount
    m

echo pt2
