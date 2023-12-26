import std/strutils

import std/sequtils

import utils

type PlatformMap = SeqGrid[char]

func parseInput(txt: string): PlatformMap =
  for line in txt.strip.splitlines:
    result.add line.toSeq

#let input = readFile("input/day14_example.txt").parseInput
let input = readFile("input/day14_input.txt").parseInput

func roll(map: var PlatformMap; loc: Vector; dir: Compass) =
  assert map[loc] == 'O'
  let u = dir.toVector2
  var
    newLoc = loc
    next = loc + u
  while map.isInside(next) and map[next] == '.':
    newLoc = next
    next = next + u
  map[loc] = '.'
  map[newLoc] = 'O'

func rollNorthAll(map: var PlatformMap) =
  for y in 0..<map.nrows:
    for x in 0..<map.ncolumns:
      if map[(x, y)] == 'O':
        roll(map, (x, y), North)

func rollSouthAll(map: var PlatformMap) =
  for y in countDown(map.nrows - 1, 0):
    for x in 0..<map.ncolumns:
      if map[(x, y)] == 'O':
        roll(map, (x, y), South)

func rollEastAll(map: var PlatformMap) =
  for x in countDown(map.ncolumns - 1, 0):
    for y in 0..<map.nrows:
      if map[(x, y)] == 'O':
        roll(map, (x, y), East)

func rollWestAll(map: var PlatformMap) =
  for x in 0..<map.ncolumns:
    for y in 0..<map.nrows:
      if map[(x, y)] == 'O':
        roll(map, (x, y), West)

func calculateLoad(map: PlatformMap): int =
  for (v, tile) in map.pairs:
    if tile == 'O':
      result.inc map.nrows - v.y

let pt1 =
  block:
    var tilted = input
    rollNorthAll tilted
    tilted.calculateLoad
echo pt1

# Part 2

proc show(map: PlatformMap) =
  for line in map.lines:
    echo line.join("")

func spinCycle(map: var PlatformMap) =
  rollNorthAll map
  rollWestAll map
  rollSouthAll map
  rollEastAll map

func checkPattern(hist: seq[int]; n: Positive): bool =
  if hist.len < n * 3:
    return false

  let h = hist.high
  for k in 0..2:
    for i in 0..<n:
      if hist[h - i] != hist[h - (n * k) - i]:
        return false
  result = true

func findPattern(hist: seq[int]): Natural =
  for n in 4..100:
    if checkPattern(hist, n):
      return n
  result = 0

func extrapolate(hist: seq[int]; period: Natural; x: int): int =
  let
    startIdx = hist.len - period
    pattern = hist[startIdx .. ^1]
  assert pattern.len == period
  result = pattern[(x - startIdx) mod period]

let pt2 =
  block:
    var
      tilted = input
      hist: seq[int] = @[tilted.calculateLoad]
      load: int
    for i in 1..1_000_000_000:
      spinCycle tilted
      hist.add tilted.calculateLoad
      let period = findPattern(hist)
      if period > 0:
        load = extrapolate(hist, period, 1_000_000_000)
        break
    load

echo pt2
