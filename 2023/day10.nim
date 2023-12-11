import std/strutils

import std/sequtils

import std/sets

import std/deques

import std/tables

import utils

type PipeMap = SeqGrid[char]

func parseInput(txt: string): PipeMap =
  for line in txt.strip.splitLines:
    result.add toSeq(line)


iterator connectingPipes(grid: PipeMap, frm: Vector): Vector =
  let
    frmVal = grid[frm]
    left = (frm.x - 1, frm.y)
    right = (frm.x + 1, frm.y)
    above = (frm.x, frm.y - 1)
    below = (frm.x, frm.y + 1)

  if grid.isInside(left) and
  grid[left] in {'-', 'F', 'L'} and
  frmVal in {'S', '-', 'J', '7'}:
    yield left

  if grid.isInside(right) and
  grid[right] in {'-', 'J', '7'} and
  frmVal in {'S', '-', 'F', 'L'}:
    yield right

  if grid.isInside(above) and
  grid[above] in {'|', 'F', '7'} and
  frmVal in {'S', '|', 'J', 'L'}:
    yield above

  if grid.isInside(below) and
  grid[below] in {'|', 'J', 'L'} and
  frmVal in {'S', '|', 'F', '7'}:
    yield below


iterator traverseBfs(grid: PipeMap, start: Vector): (Vector, int) =
  var
    seen: HashSet[Vector]
    q: Deque[(Vector, int)]

  q.addFirst (start, 0)
  seen.incl start

  while q.len > 0:
    let (cur, steps) = q.popLast
    yield (cur, steps)

    for v in grid.connectingPipes(cur):
      if v notin seen:
        seen.incl v
        q.addFirst (v, steps + 1)


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


# Part 2

proc showUnicode(grid: PipeMap) =
  const charmap = {
    '-': "─",
    '|': "│",
    'J': "╯",
    'L': "╰",
    'F': "╭",
    '7': "╮",
    '.': " ",
  }.toTable
  for line in grid:
    echo line.mapIt(charmap.getOrDefault(it, $it)).join

func isolateLoop(grid: PipeMap): PipeMap =
  # Replace all tiles not part of the loop with ground
  result = grid

  let start = grid.findStart
  let loopSet = block:
    var s: HashSet[Vector]
    for (v, _) in grid.traverseBfs(start):
      s.incl v
    s

  for v in result.locs:
    if v notin loopSet:
      result[v] = '.'


func replaceStart(grid: PipeMap): PipeMap =
  result = grid
  let start = grid.findStart
  let connSet = toSeq(grid.connectingPipes(start)).mapIt(it - start).toHashSet
  assert connSet.card == 2
  result[start] =
    if connset == [(1, 0), (-1, 0)].toHashSet: '-'
    elif connset == [(0, 1), (0, -1)].toHashSet: '|'
    elif connset == [(0, -1), (-1, 0)].toHashSet: 'J'
    elif connset == [(0, -1), (1, 0)].toHashSet: 'L'
    elif connset == [(0, 1), (-1, 0)].toHashSet: '7'
    elif connset == [(0, 1), (1, 0)].toHashSet: 'F'
    else:
      debugEcho connSet
      assert false
      '.'


type LineStateMachine = object
  inside: bool
  prevBend: char


func toggle(sm: var LineStateMachine) = sm.inside = not sm.inside


func feed(sm: var LineStateMachine, cr: char) =
  if cr == '|':
    toggle sm
  elif sm.prevBend == '\0':
    if cr in {'F', 'L'}:
      sm.prevBend = cr
  elif sm.prevBend == 'F':
    assert cr in {'-', 'J', '7'}
    if cr in {'J', '7'}:
      sm.prevBend = '\0'
    if cr == 'J':
      toggle sm
  elif sm.prevBend == 'L':
    assert cr in {'-', '7', 'J'}
    if cr in {'J', '7'}:
      sm.prevBend = '\0'
    if cr == '7':
      toggle sm


func findInside(grid: PipeMap): seq[Vector] =
  let cleanGrid = grid.isolateLoop.replaceStart
  for y, line in cleanGrid.linePairs:
    var sm: LineStateMachine
    for x, tile in line.pairs:
      sm.feed tile
      if tile == '.' and sm.inside:
        result.add (x, y)


let pt2 = input.findInside.len
echo pt2
