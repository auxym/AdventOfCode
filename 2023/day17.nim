import std/strutils

import std/sequtils

import std/heapqueue

import std/tables

import utils

type
  HeatLossMap = SeqGrid[Natural]

  Path = object
    steps: seq[Vector]
    totalHeatLoss: Natural

func parseInput(txt: string): HeatLossMap =
  for line in txt.strip.splitLines:
    result.add line.mapIt(parseInt($it).Natural)

#let input = readFile("input/day17_example.txt").parseInput
let input = readFile("input/day17_input.txt").parseInput
# let input = """
# 111111111111
# 999999999991
# 999999999991
# 999999999991
# 999999999991
# """.parseInput

func countDirection(path: Path): (Vector, Natural) =
  if path.steps.len < 2:
    ((0, 0), 0.Natural)
  else:
    let
      dir = path.steps[^1] - path.steps[^2]
      h = path.steps.high
    var n = 1.Natural
    while (h - n) >= 1:
      if (path.steps[h - n] - path.steps[h - n - 1]) == dir:
        inc n
      else:
        break
    (dir, n)

func validSteps(map: HeatLossMap; path: Path): seq[Vector] =
  let (dir, dirCount) = countDirection(path)
  let cur = path.steps[^1]
  for v in map.neighbors(cur):
    let
      reverse = (v - cur) == -dir
      sameDir = (v - cur) == dir
    if (not reverse) and not (dirCount >= 3 and sameDir):
      result.add v

func `<`(a, b: Path): bool =
  a.totalHeatLoss < b.totalHeatLoss

type PathState = array[4, Vector]

func getState(path: Path): PathState =
  for i in 0..min(3, path.steps.high):
    result[result.high - i] = path.steps[path.steps.high - i]

func findBestPath(map: HeatLossMap; start, to: Vector): Path =
  ## Dijkstra

  result.totalHeatLoss = int.high
  var
    q = initHeapQueue[Path]()
    heatLoss: Table[PathState, Natural]
  q.push Path(steps: @[start], totalHeatLoss: 0)

  while q.len > 0:
    let cur = q.pop
    if cur.steps[^1] == to:
      return cur
    for next in map.validSteps(cur):
      let
        tentative = cur.totalHeatLoss + map[next]
        tPath = Path(steps: cur.steps & next, totalHeatLoss: tentative)
        state = tPath.getState
      if tentative < heatLoss.getOrDefault(state, int.high):
        heatLoss[state] = tentative
        q.push tPath

let
  start = (0, 0)
  dest = (input.ncolumns - 1, input.nrows - 1)
  pt1Path = input.findBestPath(start, dest)

echo pt1Path.totalHeatLoss

# Part 2

func validSteps2(map: HeatLossMap; path: Path): seq[Vector] =
  let
    (dir, dirCount) = countDirection(path)
    cur = path.steps[^1]
  #debugEcho "Dir: ", dir, " Count: ", dirCount
  for v in map.neighbors(cur):
    let
      sameDir = (v - cur) == dir
      reverse = (v - cur) == -dir
    if not reverse:
      if dirCount > 0 and dirCount < 4:
        if sameDir:
          result.add v
      elif dirCount >= 10:
        if (not sameDir):
          result.add v
      else:
        result.add v

type PathState2 = object
  loc: Vector
  dir: Vector
  dirCount: Natural

func getState2(path: Path): PathState2 =
  let (dir, dirCount) = countDirection(path)
  result.loc = path.steps[^1]
  result.dir = dir
  result.dirCount = dirCount

func findBestPath2(map: HeatLossMap; start, to: Vector): Path =
  result.totalHeatLoss = int.high
  var
    q = initHeapQueue[Path]()
    heatLoss: Table[PathState2, Natural]
  q.push Path(steps: @[start], totalHeatLoss: 0)

  while q.len > 0:
    let cur = q.pop
    #debugEcho "\n", cur.steps[^1], " ", cur.totalHeatLoss
    if cur.steps[^1] == to:
      let (_, dirCount) = countDirection(cur)
      if dirCount >= 4 and dirCount <= 10:
        return cur
    for next in map.validSteps2(cur):
      let
        tentative = cur.totalHeatLoss + map[next]
        tPath = Path(steps: cur.steps & next, totalHeatLoss: tentative)
        state = tPath.getState2
      #debugEcho "  tentative: ", next, " ", tentative
      if tentative < heatLoss.getOrDefault(state, int.high):
        heatLoss[state] = tentative
        #debugEcho "  push"
        q.push tPath

let pt2Path = input.findBestPath2(start, dest)

#echo ""
#echo pt2Path.steps.mapIt($it).join("\n")
echo pt2Path.totalHeatLoss
