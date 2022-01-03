import std/deques
import std/tables
import std/sets
import std/sequtils
import std/hashes
import std/strutils
import utils

type Amphipod = enum none, A, B, C, D

type GameState = object
  tiles: array[2..4, array[2..12, Amphipod]]

type Graph[T] = Table[T, HashSet[T]]

type Board = Graph[Vector]

func isHallway(v: Vector): bool = v.y == 2
func isRoom(v: Vector): bool = v.y in 3..4 and v.x in {4, 6, 8, 10}
func isValid(v: Vector): bool = v.isHallway or v.isRoom

func `[]`(st: GameState, v: Vector): Amphipod =
  doAssert v.isValid
  st.tiles[v.y][v.x]

func `[]=`(st: var GameState, v: Vector, x: Amphipod) =
  doAssert v.isValid
  st.tiles[v.y][v.x] = x

proc parseInput(s: string): GameState =
  for (y, line) in toSeq(s.strip.splitLines).pairs:
    for (x, chr) in line.pairs:
      if chr in {'A', 'B', 'C', 'D'}:
        result[(x+1, y+1)] = case chr:
          of 'A': Amphipod.A
          of 'B': Amphipod.B
          of 'C': Amphipod.C
          of 'D': Amphipod.D
          else: Amphipod.none

func isEmpty(st: GameState, v: Vector): bool = st[v] == Amphipod.none

iterator pairs(st: GameState): (Vector, Amphipod) =
  for (y, row) in st.tiles.pairs:
    for (x, col) in row.pairs:
      if (x, y).isValid:
        yield ((x, y), st[(x, y)])

proc addBidirEdge[T](g: var Graph[T], src, tgt: T) =
  let emptySet = initHashSet[T]()
  g.mgetOrPut(src, emptySet).incl tgt
  g.mgetOrPut(tgt, emptySet).incl src

proc `$`(gs: GameState): string =
  var lines = """
#############
#...........#
###.#.#.#.###
  #.#.#.#.#
  #########
  """.strip().splitLines()
  for (loc, amphi) in gs.pairs:
    if loc.isValid and amphi != Amphipod.none:
      lines[loc.y-1][loc.x-1] = ($amphi)[0]
  result = lines.join("\n")

func createTileGraph(): Board =
  # Hallway
  for i in 3..11:
    result.addBidirEdge (i, 2), (i-1, 2)
    result.addBidirEdge (i, 2), (i+1, 2)

  # Side rooms
  for x in [4, 6, 8, 10]:
    for y in 2..3:
      result.addBidirEdge (x, y), (x, y+1)

func finalState(): GameState =
  result[(4, 3)]  = Amphipod.A
  result[(4, 4)]  = Amphipod.A
  result[(6, 3)]  = Amphipod.B
  result[(6, 4)]  = Amphipod.B
  result[(8, 3)]  = Amphipod.C
  result[(8, 4)]  = Amphipod.C
  result[(10, 3)]  = Amphipod.D
  result[(10, 4)]  = Amphipod.D

func finalRoomX(a: Amphipod): int =
  doAssert a != Amphipod.none
  result = case a:
  of Amphipod.A: 4
  of Amphipod.B: 6
  of Amphipod.C: 8
  of Amphipod.D: 10
  of Amphipod.none: int.low

func stepCost(a: Amphipod): int =
  doAssert a != Amphipod.none
  result = case a:
  of Amphipod.A: 1
  of Amphipod.B: 10
  of Amphipod.C: 100
  of Amphipod.D: 1000
  of Amphipod.none: int.low

func isLegalRoomMove(st: GameState, v: Vector, kind: Amphipod): bool =
  assert v.y == 3 or v.y == 4
  let xkind = kind.finalRoomX
  let r2 = (xkind, 4)
  result = (v.x == xkind) and (st.isEmpty(r2) or st[r2] == kind)

func isFinalSpot(state: GameState, loc: Vector, amphi: Amphipod): bool =
  if (not loc.isRoom) or (loc.x != amphi.finalRoomX):
    return false
  for i in (loc.y + 1) .. 4:
    if state[(loc.x, i)] != amphi:
      return false
  return true

func moves(curState: GameState, board: Board, src: Vector): seq[tuple[loc: Vector, energy: int]] =
  let
    # Tiles immediately outside a room. Amphipods cannot stop on these tiles
    immOutsideRoom = @[(4, 2), (6, 2), (8, 2), (10, 2)].toHashSet
    amphi = curState[src]

  # Check if we're already in correct spot
  if curState.isFinalSpot(src, amphi): return @[]

  # BFS search moves
  var
    q = initDeque[(Vector, int)]()
    visited: HashSet[Vector]
  q.addLast (src, 0)

  while q.len > 0:
    let (curloc, curEnergy) = q.popFirst
    visited.incl curloc

    if curState.isFinalSpot(curloc, amphi):
      return @[(curloc, curEnergy)]
    elif src.isRoom and curLoc.isHallway and curLoc notin immOutsideRoom:
      result.add (curLoc, curEnergy)

    for nb in board[curloc]:
      let nbEnergy = curEnergy + amphi.stepCost
      if nb in visited or not curState.isEmpty(nb):
        continue

      if (nb.isRoom and nb.x != src.x) and not isLegalRoomMove(curState, nb, amphi):
        continue

      q.addLast (nb, nbEnergy)

func nextStates(curState: GameState, board: Board): seq[(GameState, int)] =
  for (startLoc, amphi) in curState.pairs:
    if amphi == Amphipod.none: continue
    for (mvLoc, mvCost) in curState.moves(board, startLoc):
      var ns = curState
      ns[mvLoc] = amphi
      ns[startLoc] = Amphipod.none

      if isFinalSpot(ns, mvLoc, ns[mvLoc]):
        return @[(ns, mvCost)]
      else:
        result.add (ns, mvCost)

proc organizeDijkstra(start: GameState, board: Board): int =
  let target = finalState()

  var
    q: MinPriorityQueue[GameState]
    cost: Table[GameState, int]

  cost[start] = 0
  q.push(start, cost[start])
  while q.len > 0:
    let (curState, curCost) = q.popWithPriority
    if curState == target:
      return curCost

    for (nextState, nextCost) in curState.nextStates(board):
      let tentative = curCost + nextCost
      if tentative < cost.getOrDefault(nextState, int.high):
        cost[nextState] = tentative
        q.push(nextState, cost[nextState])

  return int.low

let board = createTileGraph()

let example = """
#############
#...........#
###B#C#B#D###
  #A#D#C#A#
  #########
""".parseInput

let input = """
#############
#...........#
###D#A#D#C###
  #B#C#B#A#
  #########
""".parseInput

echo organizeDijkstra(input, board)
