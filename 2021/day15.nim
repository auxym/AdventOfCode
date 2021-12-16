
import std/sequtils
import std/strutils
import std/tables
import std/heapqueue
import utils

#let input = """
#1163751742
#1381373672
#2136511328
#3694931569
#7463417111
#1319128137
#1359912421
#3125421639
#1293138521
#2311944581
#"""
let input = readFile "./input/day15_input.txt"

type RiskMap = SeqGrid[int]

func parseInput(s: string): RiskMap =
  for line in s.strip.splitLines:
    result.add line.strip.mapIt(parseInt($it))

func dijkstra(m: RiskMap, start: Vector, to: Vector): int =
  # Implementation of Dijkstra's algorithm based on:
  # http://blog.aos.sh/2018/02/24/understanding-dijkstras-algorithm/

  type DistPair = tuple[v: Vector, r: int]
  func `<`(a, b: DistPair): bool = a.r < b.r

  var
    dist: Table[Vector, int]
    q: HeapQueue[DistPair]

  dist[start] = 0
  q.push((start, dist[start]))

  while q.len > 0:
    let (cur, curRisk) = q.pop
    if cur == to:
      return curRisk
    for (nb, nbRisk) in m.neighborPairs(cur):
      let tentative = curRisk + nbRisk
      if tentative < dist.getOrDefault(nb, int.high):
        dist[nb] = tentative
        q.push (nb, dist[nb])

let
  map = parseInput input
  start = (0, 0)
  target = (map[map.high].high, map.high)

let lowestRisk = map.dijkstra(start, target)
echo lowestRisk
