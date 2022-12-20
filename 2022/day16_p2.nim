import regex
import std/strutils
import std/sequtils
import std/hashes
import std/sets
import std/options
import ./utils

type
  Valve = object
    id: string
    flow: int

  ValveGraph = WeightedAdjList[Valve]

  Path = object
    pressure: int
    opened: HashSet[Valve]
    myElapsed: int
    elephElapsed: int
    myTail: Valve
    elephTail: Valve

func hash*(v: Valve): Hash = v.id.hash

func buildWeightedGraph(graph: ValveGraph): ValveGraph =
  result = newWeightedAdjList[Valve]()
  for valve in graph.keys:
    if valve.id == "AA" or valve.flow > 0:
      result.addNode valve

  for fromValve in result.keys:
    let shortestPaths = dijkstra(graph, fromValve)
    for destValve in result.keys:
      if destValve.id == fromValve.id or destValve in result[fromValve]:
        continue
      result.addEdge(fromValve, destValve, shortestPaths[destValve])
      result.addEdge(destValve, fromValve, shortestPaths[destValve])

func parseInput(text: string): ValveGraph =
  const linepattern = re"Valve (\w\w) has flow rate=(\d+); tunnels? leads? to valves? (\w\w)(, (\w\w))*"
  var
    m: RegexMatch
    tmpValveTable = initTable[string, (Valve, seq[string])]()
  for line in text.strip.splitLines:
    doAssert line.match(linepattern, m)
    let
      id = m.group(0, line)[0]
      flow = m.group(1, line)[0]
      tunnels = m.group(4, line) & m.group(2, line)[0]
    assert id notin tmpValveTable
    tmpValveTable[id] = (Valve(id: id, flow: flow.parseInt), tunnels)

  result = newWeightedAdjList[Valve]()
  for (vid, vdata) in tmpValveTable.pairs:
    result.addNode vdata[0]
  for (vid, vdata) in tmpValveTable.pairs:
    let v = vdata[0]
    assert v in result
    for tunnel in vdata[1]:
      result.addEdge(v, tmpValveTable[tunnel][0])

  result = buildWeightedGraph result

const MinutesBeforeErupt = 26

func getRemainingValves(tail: Valve, opened: HashSet[Valve], elapsed: int, graph: ValveGraph): HashSet[Valve] =
  for v in graph.keys:
    if v in opened:
      continue
    assert v.id != tail.id
    let dist = graph[tail][v] + 1
    if elapsed + dist < MinutesBeforeErupt:
      result.incl v

func equalId(a, b: Option[Valve]): bool =
  a.isSome and b.isSome and (a.get.id == b.get.id)

iterator getNextValves(cur: Path, graph: ValveGraph): (Option[Valve], Option[Valve]) =
  var
    myRem = getRemainingValves(cur.myTail, cur.opened, cur.myElapsed, graph).mapIt(some it)
    elephRem = getRemainingValves(cur.elephTail, cur.opened, cur.elephElapsed, graph).mapIt(some it)

  if myRem.len == 0:
    myRem.add none(Valve)
  if elephRem.len == 0:
    elephRem.add none(Valve)

  for myValve in myRem:
    for elephValve in elephRem:
      if not equalId(myValve, elephValve):
        yield (myValve, elephValve)

func pruneScore(cur: Path, graph: ValveGraph): int =
  ## Quick heuristic to determine max possible pressure with this path
  var sumUnopened = block:
    var r = 0
    for valve in graph.keys:
      if valve notin cur.opened:
        r.inc valve.flow
    r
  result = cur.pressure + sumUnopened * (MinutesBeforeErupt - min(cur.myElapsed, cur.elephElapsed))

func part2(graph: ValveGraph): int =
  var stack: seq[Path]

  stack.add Path(
    myTail: Valve(id: "AA"),
    elephTail: Valve(id: "AA"),
    myElapsed: 0,
    elephElapsed: 0,
    pressure: 0,
    opened: [Valve(id: "AA")].toHashSet,
  )

  let numValves = graph.len

  while stack.len > 0:
    let cur = stack.pop
    assert cur.myElapsed <= MinutesBeforeErupt and cur.elephElapsed <= MinutesBeforeErupt

    if cur.opened.len == numValves or
      (cur.myElapsed == MinutesBeforeErupt and cur.elephElapsed == MinutesBeforeErupt):
      if cur.pressure > result:
        result = cur.pressure
      continue
    elif pruneScore(cur, graph) <= result:
      continue

    for (myValve, elephValve) in getNextValves(cur, graph):
      var next = cur

      if myValve.isSome:
        next.myTail = myValve.get
        next.opened.incl myValve.get
        next.myElapsed.inc graph[cur.myTail][next.myTail] + 1
        next.pressure.inc next.myTail.flow * (MinutesBeforeErupt - next.myElapsed)
      else:
        next.myElapsed = MinutesBeforeErupt

      if elephValve.isSome:
        next.elephTail = elephValve.get
        next.opened.incl elephValve.get
        next.elephElapsed.inc graph[cur.elephTail][next.elephTail] + 1
        next.pressure.inc next.elephTail.flow * (MinutesBeforeErupt - next.elephElapsed)
      else:
        next.elephElapsed = MinutesBeforeErupt

      stack.add next

const fname = "./input/day16_input.txt"
let input = readFile(fname).parseInput

echo part2(input)
