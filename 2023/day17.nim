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

func validSteps(map: HeatLossMap; path: Path): seq[Vector] =
  let (dir, dirCount) =
    if path.steps.len < 2:
      ((0, 0), 0)
    else:
      let
        dir = path.steps[^1] - path.steps[^2]
        h = path.steps.high
      var n = 1
      while (h - n) >= 1:
        if (path.steps[h - n] - path.steps[h - n - 1]) == dir:
          inc n
        else:
          break
      (dir, n)

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
