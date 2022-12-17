import regex
import std/strutils
import std/sequtils
import std/hashes
import std/sets
import std/strformat
import ./utils

type
  Valve = object
    id: string
    flow: int

  ValveGraph = WeightedAdjList[Valve]

  Path = object
    elapsed: int
    pressure: int
    valveSeq: seq[Valve]
    remainingValves: HashSet[Valve]

func hash*(v: Valve): Hash = v.id.hash

func tail*(p: Path): Valve = p.valveSeq[^1]
func previous*(p: Path): Valve = p.valveSeq[^2]

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

const MinutesBeforeErupt = 30

func filterRemainingValves(cur: Path, graph: ValveGraph): HashSet[Valve] =
  for v in cur.remainingValves:
    assert v.id != cur.tail.id
    let dist = graph[cur.tail][v] + 1
    if cur.elapsed + dist <= MinutesBeforeErupt:
      result.incl v

func part1(graph: ValveGraph): int =
  var stack: seq[Path]
  stack.add Path(
    valveSeq: @[Valve(id: "AA")],
    elapsed: 0,
    pressure: 0,
    remainingValves: toSeq(graph.keys).filterIt(it.id  != "AA").toHashSet
  )

  while stack.len > 0:
    let cur = stack.pop
    assert cur.elapsed <= MinutesBeforeErupt
    let filteredUnopened = filterRemainingValves(cur, graph)

    if cur.elapsed == MinutesBeforeErupt or filteredUnopened.len == 0:
      if cur.pressure > result:
        result = cur.pressure
      continue

    for nextValve in filteredUnopened:
      var next = cur
      next.valveSeq.add nextValve
      next.remainingValves = filteredUnopened
      next.remainingValves.excl nextValve

      next.elapsed.inc graph[cur.tail][nextValve] + 1
      assert next.elapsed <= MinutesBeforeErupt

      let dp = nextValve.flow * (MinutesBeforeErupt - next.elapsed)
      next.pressure.inc dp

      stack.add next

const fname = "./input/day16_input.txt"
let input = readFile(fname).parseInput

echo part1(input)
