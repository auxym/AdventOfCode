import regex
import std/heapqueue
import std/sequtils
import std/strutils
import std/algorithm
import std/tables
import std/strformat
import std/terminal
import std/sets

type
  Compass* = enum North, East, South, West
  Vector* = tuple[x, y: int]
  WeightedEdge*[T] = tuple[elem: T, weight: int]
  WeightedAdjList*[T] = TableRef[T, Table[T, int]]
  ArrayGrid*[a, b: static[int], T] = array[a, array[b, T]]
  SeqGrid*[T] = seq[seq[T]]

type PriorityQueueElem*[T] = object
  prio: int
  val: T

type MinPriorityQueue*[T] = HeapQueue[PriorityQueueElem[T]]

proc `<`*[T](a, b: PriorityQueueElem[T]): bool = a.prio < b.prio

proc push*[T](q: var MinPriorityQueue[T], x: T, priority: int) =
  q.push PriorityQueueElem[T](prio: priority, val: x)

proc pop*[T](q: var MinPriorityQueue[T]): T =
  let e: PriorityQueueElem[T] = heapqueue.pop(q)
  result = e.val

proc popWithPriority*[T](q: var MinPriorityQueue[T]): (T, int) =
  let e: PriorityQueueElem[T] = heapqueue.pop(q)
  result = (e.val, e.prio)

func cw*(c: Compass): Compass =
  if c == Compass.high:
    Compass.low
  else:
    c.succ

func ccw*(c: Compass): Compass =
  if c == Compass.low:
    Compass.high
  else:
    c.pred

func cw*(v: Vector): Vector = # Rotate 90 degrees clockwise
  (v.y, -v.x)

func ccw*(v: Vector): Vector = # Rotate 90 degrees counter-clockwise
  (-v.y, v.x)

func `+`*(a, b: Vector): Vector = (a.x + b.x, a.y + b.y)
func `-`*(a, b: Vector): Vector = (a.x - b.x, a.y - b.y)
func `*`*(u: int, v: Vector): Vector = (u * v.x, u * v.y)
func `/`*(a: Vector, b: int): Vector = (a.x div b, a.y div b)

func inc*(a: var Vector, b: Vector) =
  a.x.inc(b.x)
  a.y.inc(b.y)

func manhattan*(a, b: Vector): Natural =
  abs(b.x - a.x) + abs(b.y - a.y)

func toVector*(d: Compass): Vector =
  case d
  of North: (0, 1)
  of East: (1, 0)
  of West: (-1, 0)
  of South: (0, -1)

func getInts*(s: string): seq[int] =
  let expint = re"-?\d+"
  result = s.findAndCaptureAll(expint).map(parseInt)

func digits*(i: int): seq[int] =
  result = @[]
  var
    j = i
  while j > 0:
    result.add j mod 10
    j = j div 10
  result = result.reversed

func toBitSet*[T: Ordinal](s: openArray[T]): set[T] =
  for e in s: result.incl e

func toBitSet*(s: string): set[char] =
  for c in s: result.incl c

func newWeightedAdjList*[T](initialSize = 0): WeightedAdjList[T] =
  if initialSize <= 0:
    newTable[T, Table[T, int]]()
  else:
    newTable[T, Table[T, int]](initialSize)

func addEdge*[T](g: var WeightedAdjList[T], frm: T, to: T, weight: int = 1) =
  if frm notin g:
    g[frm] = {to: weight}.toTable
  else:
    g[frm][to] = weight

func addNode*[T](g: var WeightedAdjList[T], node: T) =
  if node notin g: g[node] = newSeq[WeightedEdge[T]]().toTable

iterator traverseDfs*[T](g: WeightedAdjList[T], start: T): WeightedEdge[T] =
  var
    stack: seq[WeightedEdge[T]]
    cur: WeightedEdge[T]
  stack.add (start, 0)
  while stack.len > 0:
    cur = stack.pop
    yield cur
    if cur.elem notin g: continue
    for (elem, wt) in g[cur.elem].pairs:
      stack.add (elem, wt)

iterator combinations*(n, k: int): seq[int] =
  let hi = n-1
  var
    i: int
    result = toSeq(0..<k)
  yield result
  while true:
    i = k - 1
    if result[i] < hi:
      inc result[i]
    else:
      dec i
      while i >= 0 and result[i] >= (result[i+1] - 1):
        dec i
      if i < 0: break
      inc result[i]
    for j in (i+1..k-1):
      result[j] = result[i] + (j - i)
    yield result

iterator combinations*[T](itms: seq[T], k: Natural): seq[T] =
  for indices in combinations(itms.len, k):
    yield indices.mapIt(itms[it])

iterator product*(n, k: int): seq[int] =
  let hi = n - 1
  var
    cur: seq[int]
    j = 0
  for i in 0..<k: cur.add 0
  while true:
    yield cur

    j = cur.high
    while j >= 0 and cur[j] == hi:
      dec j
    if j < 0:
      break

    cur[j].inc
    for i in (j + 1)..cur.high:
      cur[i] = 0

iterator product*[T](itms: seq[T], repeat: Natural): seq[T] =
  for indices in product(itms.len, repeat):
    yield indices.mapIt(itms[it])

func toBitString*(a: SomeInteger, size = 64): string =
  let spec = fmt"0{size}b"
  formatValue(result, a, spec)

iterator chain*[T](sequences: openArray[seq[T]]): T =
  for s in sequences:
    for e in s: yield e

proc dEchoHl*(s: string, hlPos: set[int16]) =
  var hlState = false
  for i, c in s.pairs:
    if i.int16 in hlPos and not hlState:
      stdout.setForegroundColor(fgRed)
      hlState = true
    elif hlState and i.int16 notin hlPos:
      stdout.resetAttributes
      hlState = false
    stdout.write(c)
  stdout.resetAttributes
  stdout.write "\n"

func peek*[T](s: HashSet[T]): T =
  for e in s: return e

func `[]`*[a, b, T](g: ArrayGrid[a, b, T], v: Vector): T =
  g[v.y][v.x]

func `[]`*[a, b, T](g: var ArrayGrid[a, b, T], v: Vector): var T =
  g[v.y][v.x]

func `[]=`*[a, b, T](g: var ArrayGrid[a, b, T], v: Vector, val: T) =
  g[v.y][v.x] = val

iterator tilePairs*[a, b, T](g: ArrayGrid[a, b, T]): (Vector, T) =
  for (i, row) in g.pairs:
    for (j, elem) in row.pairs:
      yield ((j, i), elem)

iterator tilemPairs*[a, b, T](g: var ArrayGrid[a, b, T]): (Vector, var T) =
  for (i, row) in g.mpairs:
    for (j, elem) in row.mpairs:
      yield ((j, i), elem)

iterator adjacentVectors*[a, b, T](g: ArrayGrid[a, b, T], at: Vector, diag = true): Vector =
  if at.x > 0:
    yield (at.x - 1, at.y)
  if at.x < g[at.y].high:
    yield (at.x + 1, at.y)
  if at.y > 0:
    yield (at.x, at.y - 1)
  if at.y < g.high:
    yield (at.x, at.y + 1)

  if diag:
    if at.x > 0 and at.y > 0:
      yield (at.x - 1, at.y - 1)
    if at.x > 0 and at.y < g.high:
      yield (at.x - 1, at.y + 1)
    if at.x < g[at.y].high and at.y > 0:
      yield (at.x + 1, at.y - 1)
    if at.x < g[at.y].high and at.y < g.high:
      yield (at.x + 1, at.y + 1)

iterator adjacentPairs*[a, b, T](g: ArrayGrid[a, b, T], at: Vector, diag = true): (Vector, T) =
  for v in g.adjacentVectors(at, diag):
    yield (v, g[v])

iterator adjacent*[a, b, T](g: ArrayGrid[a, b, T], at: Vector, diag = true): T =
  for v in g.adjacentVectors(at, diag):
    yield g[v]

func parseVector*(s: string): Vector =
  let parts = s.getInts
  assert parts.len == 2
  result = (parts[0], parts[1])

func `[]`*[T](g: SeqGrid[T], v: Vector): T =
  g[v.y][v.x]

iterator neighbors*[T](g: SeqGrid[T], v: Vector): Vector =
  for disp in [(1, 0), (-1, 0), (0, 1), (0, -1)]:
    let nbv = v + disp
    if nbv.x in 0..(g[v.y].high) and nbv.y in 0..g.high:
      yield nbv

iterator neighborPairs*[T](g: SeqGrid[T], v: Vector): (Vector, T) =
  for nbv in g.neighbors(v):
    yield(nbv, g[nbv])

iterator locs*[T](g: SeqGrid[T]): Vector =
  for i in 0..g.high:
    for j in 0..g[i].high:
      yield (j, i)



export
  tables.contains,
  tables.hasKey,
  tables.keys, tables.values, tables.pairs,
  tables.`[]=`,
  tables.`[]`,
  heapqueue.len
