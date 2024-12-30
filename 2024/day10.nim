import std/strutils
import std/sequtils
import std/sets
import utils

type TopoMap = SeqGrid[int]

func parseInput(s: string): TopoMap =
  for line in s.strip.splitLines:
    result.add line.mapIt(parseInt($it))

let input = readFile("./input/day10_input.txt").parseInput

func scoreTrailhead(map: TopoMap, head: Vector): int =
  # Depth first search
  var
    stack = @[head]
    seen: HashSet[Vector]
  while stack.len > 0:
    let cur = stack.pop
    if cur in seen:
      continue
    seen.incl cur

    let curHeight = map[cur]
    if curHeight == 9:
      inc result
    else:
      for (loc, height) in map.neighborPairs(cur):
        if height == curHeight + 1:
          stack.add loc

func p1(input: TopoMap): int =
  for loc in input.locs:
    if input[loc] == 0:
      result.inc scoreTrailhead(input, loc)

echo p1(input)

func scoreTrailhead2(map: TopoMap, head: Vector): int =
  # Depth first search
  var stack = @[head]
  while stack.len > 0:
    let
      cur = stack.pop
      curHeight = map[cur]
    if curHeight == 9:
      inc result
    else:
      for (loc, height) in map.neighborPairs(cur):
        if height == curHeight + 1:
          stack.add loc

func p2(input: TopoMap): int =
  for loc in input.locs:
    if input[loc] == 0:
      result.inc scoreTrailhead2(input, loc)

echo p2(input)