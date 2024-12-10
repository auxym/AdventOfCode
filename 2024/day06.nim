import std/strutils
import std/sequtils
import std/enumerate
import std/sets
import std/options
import utils

type
  GuardState = object
    loc: Vector
    direction: Vector

  Input = object
    obstructions: HashSet[Vector]
    extents: Vector
    guard: GuardState

func parseInput(s: string): Input =
  for (y, line) in enumerate(ritems(s.strip.splitLines)):
    result.extents.y = y
    for (x, c) in line.pairs:
      result.extents.x = x
      case c
      of '#':
        result.obstructions.incl (x, y)
      of '^':
        result.guard.loc = (x, y)
        result.guard.direction = (0, 1)
      of '.':
        discard
      else:
        raise newException(CatchableError, "Unexpected character " & c)

func isInExtents(input: Input, v: Vector): bool =
  v.x >= 0 and v.y >= 0 and v.x <= input.extents.x and v.y <= input.extents.y

func next(g: GuardState): GuardState =
  result = g
  result.loc.inc result.direction

proc showmap(
    input: Input,
    guard: GuardState,
    visited: Option[HashSet[Vector]] = none(HashSet[Vector]),
) =
  for y in countdown(input.extents.y, 0):
    var ln = ""
    for x in 0..input.extents.x:
      ln.add block:
        if (x, y) in input.obstructions:
          '#'
        elif (x, y) == guard.loc:
          block:
            if guard.direction == (0, 1):
              '^'
            elif guard.direction == (0, -1):
              'v'
            elif guard.direction == (1, 0):
              '>'
            else:
              '<'
        elif visited.isSome and (x, y) in visited.get:
          'X'
        else:
          '.'
    echo ln

proc p1(input: Input): int =
  var guard = input.guard
  var visited: HashSet[Vector]

  while input.isInExtents(guard.loc):
    visited.incl guard.loc
    #showmap(input, guard)
    if guard.next.loc in input.obstructions:
      guard.direction = guard.direction.cw
    else:
      guard = guard.next
  #showmap(input, guard.next, some(visited))
  result = visited.card

let input = readFile("./input/day06_input.txt").parseInput

echo p1(input)

# Part 2

type
  ExitCondition = enum
    OutOfBounds
    CycleDetected

  SimResult = object
    states: HashSet[GuardState]
    exit: ExitCondition

proc simulate(input: Input): SimResult =
  var guard = input.guard

  while true:
    if not isInExtents(input, guard.loc):
      result.exit = OutOfBounds
      break
    elif guard in result.states:
      result.exit = CycleDetected
      break

    result.states.incl guard
    if guard.next.loc in input.obstructions:
      guard.direction = guard.direction.cw
    else:
      guard = guard.next

proc p2(input: Input): int =
  let
    obsCandidates =
      block:
        let sim = simulate(input)
        assert sim.exit == OutOfBounds
        var locs: HashSet[Vector]
        for st in sim.states:
          locs.incl st.loc
        locs

  for newObs in obsCandidates:
    if newObs == input.guard.loc:
      continue
    var modInput = input
    modInput.obstructions.incl newObs
    if simulate(modInput).exit == CycleDetected:
      inc result

echo p2(input)
