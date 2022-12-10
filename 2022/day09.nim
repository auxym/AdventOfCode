import std/sets
import std/strutils
import std/math
import ./utils

type RopeState = object
  head, tail: Vector

proc isAdjacent(a, b: Vector): bool =
  let d = a - b
  result = abs(d.x) <= 1 and abs(d.y) <= 1

proc dirVector(v: Vector): Vector =
  (sgn(v.x), sgn(v.y))

proc move(rope: var RopeState, by: Vector) =
  rope.head.inc by
  assert abs(by.x) + abs(by.y) == 1
  if not isAdjacent(rope.head, rope.tail):
    if rope.head.x == rope.tail.x or rope.head.y == rope.tail.y:
      rope.tail.inc by
      assert isAdjacent(rope.head, rope.tail)
    else:
      rope.tail = rope.tail + dirVector(rope.head - rope.tail)
      assert isAdjacent(rope.head, rope.tail)

proc toVector(c: char): Vector =
  assert c in {'U', 'D', 'L', 'R'}
  result = case c:
    of 'U': (0, -1)
    of 'D': (0, 1)
    of 'R': (1, 0)
    of 'L': (-1, 0)
    else: (0, 0)

func part1(input: string): int =
  var
    tailpos = initHashSet[Vector]()
    rope: RopeState
  tailpos.incl rope.tail
  for line in input.strip.splitLines:
    let parts = line.splitWhitespace
    for i in 0 ..< (parseInt parts[1]):
      rope.move(line[0].toVector)
      tailpos.incl rope.tail

  result = tailpos.card

let input = readFile("./input/day09_input.txt")

echo part1(input)

# Part 2

type LongRope = array[10, Vector]

proc move(rope: var LongRope, by: Vector) =
  rope[0].inc by
  assert abs(by.x) + abs(by.y) == 1
  for i in 1..rope.high:
    let
      head = rope[i - 1]
      tail = rope[i]
    if not isAdjacent(head, tail):
      rope[i] = tail + dirVector(head - tail)
      assert isAdjacent(head, rope[i])

func part2(input: string): int =
  var
    tailpos = initHashSet[Vector]()
    rope: LongRope
  tailpos.incl rope[rope.high]
  for line in input.strip.splitLines:
    let parts = line.splitWhitespace
    for i in 0 ..< (parseInt parts[1]):
      rope.move(line[0].toVector)
      tailpos.incl rope[rope.high]

  result = tailpos.card

echo part2(input)
