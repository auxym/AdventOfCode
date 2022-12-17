import std/strutils
import std/sequtils
import std/sets
import ./utils

let jetSequence = readFile("./input/day17_input.txt").strip

type JetState = object
  vals: string
  cur: Natural

func jetToVector(c: char): Vector =
  if c == '<': result = (-1, 0)
  elif c == '>': result = (1, 0)
  else: doAssert false

proc initJetState: JetState =
  JetState(vals: jetSequence, cur: 0)

func next(jets: var JetState): Vector =
  result = jets.vals[jets.cur].jetToVector
  jets.cur.inc
  jets.cur = jets.cur mod jets.vals.len

const RockShapes: array[5, HashSet[Vector]] = [
  # ####
  @[(0, 0), (1, 0), (2, 0), (3, 0)].toHashSet,

  # .#.
  # ###
  # .#.
  @[(1, 0), (0, 1), (1, 1), (2, 1), (1, 2)].toHashSet,

  # ..#
  # ..#
  # ###
  @[(0, 0), (1, 0), (2, 0), (2, 1), (2, 2)].toHashSet,

  # #
  # #
  # #
  # #
  @[(0, 0), (0, 1), (0, 2), (0, 3)].toHashSet,


  # ##
  # ##
  @[(0, 0), (0, 1), (1, 0), (1, 1)].toHashSet,
]

func corners(s: HashSet[Vector]): (Vector, Vector) =
  doAssert s.len > 0
  result[0] = (int.high, int.high)
  result[1] = (int.low, int.low)
  for v in s:
    if v.x < result[0].x:
      result[0].x = v.x
    if v.x > result[1].x:
      result[1].x = v.x
    if v.y < result[0].y:
      result[0].y = v.y
    if v.y > result[1].y:
      result[1].y = v.y

func `+`(s: HashSet[Vector], x: Vector): HashSet[Vector] =
  for v in s:
    result.incl v + x

func isInsideWalls(rock: HashSet[Vector]): bool =
  let bbox = rock.corners
  result = bbox[0].x >= 0 and bbox[1].x <= 6

func collision(a, b: HashSet[Vector]): bool =
  (a * b).len > 0

proc addRock(pile: var HashSet[Vector], jets: var JetState, rockIdx: int) =
  let
    pileTop = if pile.len == 0: -1 else: pile.corners[1].y
    spawn = (2, pileTop + 4)

  var
    rock = RockShapes[rockIdx] + spawn
    atRest = false

  while not atRest:
    block:
      let
        j = jets.next
        jettedRock = rock + j
      if jettedRock.isInsideWalls and not collision(jettedRock, pile):
        rock = jettedRock

    block:
      let fallenRock = rock + (0, -1)
      if fallenRock.corners[0].y >= 0 and not collision(fallenRock, pile):
        rock = fallenRock
      else:
        atRest = true

  pile.incl rock

proc part1(n: int): int =
  var
    shapeIdx = 0
    jets = initJetState()
    pile = initHashSet[Vector]()

  for i in 0 ..< n:
    pile.addRock(jets, shapeIdx)
    shapeIdx = (shapeIdx + 1)  mod RockShapes.len

  result = pile.corners()[1].y + 1

# Part 2

func height(pile: HashSet[Vector]): int =
  if pile.len == 0:
    0
  else:
    pile.corners[1].y + 1

type SeenTableValue = ref object
  prevIter: int
  di: seq[int]
  prevH: int
  dh: seq[int]

proc part2(n: int64): int64 =
  var
    shapeIdx = 0
    jets = initJetState()
    pile = initHashSet[Vector]()
    seen: Table[(int, int), SeenTableValue]
    history: seq[int] = @[0]

  for i in 0 ..< 10_000:
    pile.addRock(jets, shapeIdx)
    shapeIdx = (shapeIdx + 1)  mod RockShapes.len

    let
      p = (shapeIdx, jets.cur)
      h = pile.height
    history.add h
    if p in seen:
      var val = seen[p]
      val.di.add i - val.prevIter
      val.dh.add h - val.prevH
      val.prevIter = i
      val.prevH = h
      if val.dh.len > 1 and val.dh[0] == val.dh[1]:
        let
          di = val.di[0]
          dh = val.dh[0]
          baseIter = val.prevIter - val.di[0]
          baseHeight = val.prevH - val.dh[0]
          pattern = history[^(val.di[0] + 1) .. ^2].mapIt(it - baseHeight)
        return ((n - 1 - baseIter) div di) * dh + baseHeight + pattern[(n - 1 - baseIter) mod di]
    else:
      var val = new SeenTableValue
      val.prevIter = i
      val.prevH = h
      seen[p] = val

const
  Part1Iterations = 2022
  Part2Iterations = 1_000_000_000_000'i64

echo part1(Part1Iterations)
echo part2(Part2Iterations)
