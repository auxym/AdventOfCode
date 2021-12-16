import std/sequtils
import std/strutils
import std/tables
import std/heapqueue
import utils

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
  lowestRisk = map.dijkstra(start, target)
echo lowestRisk

# Part 2

func genPart2Map(m: RiskMap): RiskMap =
  for rowTile in 0..4:
    for row in m:
      var newRow: seq[int]
      for colTile in 0..4:
        let k = colTile + rowTile
        newRow = newRow & row.mapIt((it + k - 1) mod 9 + 1)
      result.add newRow

let
  pt2Map = map.genPart2Map
  target2 = (pt2Map[pt2Map.high].high, pt2Map.high)
  lowestDist2 = pt2Map.dijkstra(start, target2)
echo lowestDist2
