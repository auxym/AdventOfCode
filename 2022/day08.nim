import std/strutils
import std/sequtils
import ./utils

type TreeGrid = SeqGrid[int]

func parseInput(s: string): TreeGrid =
  for line in s.strip.splitLines:
    result.add line.mapIt(($it).parseInt)

let input = readFile("./input/day08_input.txt").parseInput

func part1(grid: TreeGrid): int =
  for loc in grid.locs:
    let tree = grid[loc]
    if grid.isEdge(loc):
      result.inc
      continue
    for direction in [(1, 0), (-1, 0), (0, 1), (0, -1)]:
      var
        otherLoc = loc
        isVisible = true
      while isVisible and not grid.isEdge(otherLoc):
        otherLoc.inc direction
        isVisible = grid[otherLoc] < tree
      if isVisible:
        result.inc
        break

echo part1(input)

# Part 2

func scenicScore(grid: TreeGrid, loc: Vector): int =
  let tree = grid[loc]
  result = 1
  for direction in [(1, 0), (-1, 0), (0, 1), (0, -1)]:
    var
      dirScore = 0
      otherLoc = loc
    while true:
      otherLoc.inc direction
      if not grid.isInside(otherLoc):
        break
      dirScore.inc
      if grid[otherLoc] >= tree:
        break
    result = result * dirScore

func part2(grid: TreeGrid): int =
  for loc in grid.locs:
    let score = scenicScore(grid, loc)
    if score > result:
      result = score

echo part2(input)
