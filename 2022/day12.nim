import std/strutils
import std/sequtils
import std/hashes
import ./utils

type
  Height = range['a' .. 'z']
  HeightmapTile = object
    loc: Vector
    height: Height

  HeightmapGraph = WeightedAdjList[HeightmapTile]

  PuzzleInput = object
    graph: HeightmapGraph
    startPos, endPos: HeightmapTile

func hash(t: HeightmapTile): Hash =
  t.loc.hash

func toHeight(c: char): Height =
  result = case c:
    of {'a'..'z'}: c
    of 'S': 'a'
    of 'E': 'z'
    else: char(0)
  assert result.ord > 0

func parseInput(str: string): PuzzleInput =
  let grid = block:
    var g: SeqGrid[char]
    for line in str.strip.splitLines:
      g.add toSeq(line)
    g

  result.graph = newWeightedAdjList[HeightmapTile]()
  for vec in grid.locs:
    let
      c = grid[vec]
      curTile = HeightmapTile(loc: vec, height: c.toHeight)
    result.graph.addNode curTile

    if c == 'S':
      assert result.startPos.height.ord == 0 # Ensure start is only found once
      result.startPos = curTile
    if c == 'E':
      assert result.endPos.height.ord == 0 # Ensure end is only found once
      result.endPos = curTile

    for (nb, nbChar) in grid.neighborPairs(vec):
      let nbTile = HeightmapTile(loc: nb, height: nbChar.toHeight)
      if nbTile.height <= curTile.height.succ:
        result.graph.addEdge(curTile, nbTile)

let input = readFile("./input/day12_input.txt").parseInput

# Part 1
echo input.graph.dijkstra(input.startPos, input.endPos)

# Part 2
proc part2: int =
  result = int.high
  let distances = input.graph.inverted().dijkstra(input.endPos)
  for (tile, dist) in distances.pairs:
    if tile.height == 'a' and dist < result:
      result = dist

echo part2()
