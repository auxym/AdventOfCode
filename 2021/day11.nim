import utils
import std/strutils
import std/strformat

#const input = """
#5483143223
#2745854711
#5264556173
#6141336146
#6357385478
#4167524645
#2176841721
#6882881134
#4846848554
#5283751526
#"""

const input = readFile("./input/day11_input.txt")

const
  numRows = input.strip().splitLines.len
  numCols = input.strip().splitLines[0].len

type Octopus = object
  energy: int
  hasFlashed: bool

type OctopusGrid = ArrayGrid[numRows, numCols, Octopus]

func parseInput(s: string): OctopusGrid =
  let lines = s.strip.splitLines
  for i in 0..result.high:
    for j in 0..result[i].high:
      let e: int = parseInt $lines[i][j]
      result[i][j] = Octopus(energy: e, hasFlashed: false)

func step(g: OctopusGrid): tuple[newGrid: OctopusGrid, flashCount: int] =
  result.newGrid = g
  for (at, oc) in result.newGrid.tilemPairs:
    oc.energy.inc
    oc.hasFlashed = false

  var flashCount = int.high
  while flashCount > 0:
    flashCount = 0
    var tmp = result.newGrid
    for (at, oc) in result.newGrid.tilePairs:
      if oc.energy > 9 and not oc.hasFlashed:
        flashCount.inc
        result.flashCount.inc
        tmp[at].hasFlashed = true
        for v in tmp.adjacentVectors(at):
          tmp[v].energy.inc
    result.newGrid = tmp

  for (at, oc) in result.newGrid.tilemPairs:
    if oc.hasFlashed:
      oc.energy = 0

var
  totalFlashes = 0
  grid = input.parseInput
for i in 1..100:
  let (newGrid, f) = grid.step
  grid = newGrid
  totalFlashes.inc f

echo totalFlashes

# Part 2

func allFlashed(g: OctopusGrid): bool =
  for (v, oc) in g.tilePairs:
    if not oc.hasFlashed:
      return false
  return true

grid = input.parseInput
var i = 0
while not grid.allFlashed:
  let (newGrid, f) = grid.step
  grid = newGrid
  inc i
echo i
