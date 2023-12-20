import std/strutils

import std/sequtils

import std/algorithm

import utils

type PlatformMap = SeqGrid[char]

func parseInput(txt: string): PlatformMap =
  for line in txt.strip.splitlines:
    result.add line.toSeq

#let input = readFile("input/day13_example.txt").parseInput
let input = readFile("input/day14_input.txt").parseInput

func rollNorth(map: var PlatformMap; loc: Vector) =
  assert map[loc] == 'O'
  let dir = (0, -1)
  var
    newLoc = loc
    next = loc + dir
  while map.isInside(next) and map[next] == '.':
    newLoc = next
    next = next + dir
  map[loc] = '.'
  map[newLoc] = 'O'

func rollNorthAll(map: PlatformMap): PlatformMap =
  result = map
  for y in 0..<map.nrows:
    for x in 0..<map.ncolumns:
      if map[(x, y)] == 'O':
        rollNorth(result, (x, y))

func calculateLoad(map: PlatformMap): Natural =
  for (v, tile) in map.pairs:
    if tile == 'O':
      result.inc map.nrows - v.y

let rmap = input.rollNorthAll
for row in rmap.lines:
  echo row.join("")

let pt1 = input.rollNorthAll.calculateLoad
echo pt1
