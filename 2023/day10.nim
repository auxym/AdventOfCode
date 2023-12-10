import std/strutils

import std/sequtils

import std/sets

import std/deques

import utils

type PipeMap = SeqGrid[char]

func parseInput(txt: string): PipeMap =
  for line in txt.strip.splitLines:
    result.add toSeq(line)

iterator traverseBfs(grid: PipeMap, start: Vector): (Vector, int) =
  var
    seen: HashSet[Vector]
    q: Deque[(Vector, int)]

  q.addFirst (start, 0)
  seen.incl start

  while q.len > 0:
    let (cur, steps) = q.popLast
    yield (cur, steps)

    let
      curVal = grid[cur]
      left = (cur.x - 1, cur.y)
      right = (cur.x + 1, cur.y)
      above = (cur.x, cur.y - 1)
      below = (cur.x, cur.y + 1)

    if left notin seen and
    grid.isInside(left) and
    grid[left] in {'-', 'F', 'L'} and
    curVal in {'S', '-', 'J', '7'}:
      q.addFirst (left, steps + 1)
      seen.incl left

    if right notin seen and
    grid.isInside(right) and
    grid[right] in {'-', 'J', '7'} and
    curVal in {'S', '-', 'F', 'L'}:
      q.addFirst (right, steps + 1)
      seen.incl right

    if above notin seen and
    grid.isInside(above) and
    grid[above] in {'|', 'F', '7'} and
    curVal in {'S', '|', 'J', 'L'}:
      q.addFirst (above, steps + 1)
      seen.incl above

    if below notin seen and
    grid.isInside(below) and
    grid[below] in {'|', 'J', 'L'} and
    curVal in {'S', '|', 'F', '7'}:
      q.addFirst (below, steps + 1)
      seen.incl below

func findStart(grid: PipeMap): Vector =
  for (v, tile) in grid.pairs:
    if tile == 'S':
      return v
  assert false # make sure we found it

let
  input = readFile("input/day10_input.txt").parseInput
  start = input.findStart

let pt1 = block:
  var maxSteps = -1
  for (v, steps) in input.traverseBfs(start):
    if steps > maxSteps: maxSteps = steps
  maxSteps

echo pt1
