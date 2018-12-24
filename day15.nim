import sequtils
import strutils
import deques
import algorithm
import sets

type
    Point = tuple[x, y: int]
    TileKind = enum Open, Wall
    UnitKind = enum Goblin, Elf
    Grid = seq[seq[TileKind]]
    State = ref object
        units: seq[Unit]
        grid: Grid

    TurnResult = enum NoResult, EndCombat

    Unit = ref object
        kind: UnitKind
        loc: Point
        ap: int
        hp: int

    Path = seq[Point]

func newUnit(kind: UnitKind, x, y: int): Unit =
    new result
    result.kind = kind
    result.ap = 3
    result.hp = 200
    result.loc = (x, y)

func `$`(u: Unit): string =
    $u.kind & " (loc: " & $u.loc & ", hp: " & $u.hp & ")"

func parseState(text: string): State =
    var g: Grid
    var
        units: seq[Unit]
        x, y = 0

    for line in text.splitLines():
        var gl: seq[TileKind]
        x = 0
        for chr in line:
            case chr:
                of '#':
                    gl.add Wall
                of '.':
                    gl.add Open
                of 'G':
                    units.add newUnit(Goblin, x, y)
                    gl.add Open
                of 'E':
                    units.add newUnit(Elf, x, y)
                    gl.add Open
                else:
                    raise newException(ValueError, "Unknown char " & chr)
            inc x
        g.add gl
        inc y
        
    new result
    result.grid = g
    result.units = units
        
func dist(a, b: Point): int =
    abs(b.x - a.x) + abs(b.y - a.y)

func cmpReading(a, b: Point): int =
    result = cmp(a.y, b.y)
    if result == 0:
        result = cmp(a.x, b.x)

func cmpReading(a, b: Unit): int =
    result = cmpReading(a.loc, b.loc)

func cmpTargets(a, b: Unit): int =
    result = cmp(a.hp, b.hp)
    if result == 0:
        result = cmpReading(a, b)

func isAlive(u: Unit): bool = u.hp > 0

func isValidMove(loc: Point, s: State): bool =
    result = true
    if s.grid[loc.y][loc.x] == Wall:
        return false
    for u in s.units:
        if u.isAlive() and u.loc == loc:
            return false

func reachableNeighbors(s: State, loc: Point): seq[Point] =
    result = @[
        (loc.x + 1, loc.y),
        (loc.x - 1, loc.y),
        (loc.x, loc.y + 1),
        (loc.x, loc.y - 1)
    ]
    return result.filterIt(isValidMove(it, s))

func getAllTargets(u: Unit, s: State): seq[Unit] =
    result = s.units.filterIt(it.isAlive and it.kind != u.kind)

func dest(p: Path): Point =
    p[p.high]

func cmpDest(a, b: Path): int =
    return cmpReading(a.dest, b.dest)

func cmpFirstMove(a, b: Path): int =
    return cmpReading(a[1], b[1])

func bfs(s: State, source: Point, dests: HashSet[Point]): seq[Path] =
    var q = initDeque[Path]()
    var visited = initSet[Point]()

    q.addLast @[source]
    while q.len > 0:
        let cur = q.popFirst()
        let last = cur[cur.high]
        if dests.contains(last):
            result.add cur
        for n in s.reachableNeighbors(last):
            if visited.contains(n):
                continue
            var p = cur
            p.add n
            q.addLast p
        visited.incl last

func selectPath(paths: seq[Path]): Path =
    let shortestLen = min(paths.mapIt(it.len))
    var shortPaths = paths.filterIt(it.len == shortestLen)

    assert shortPaths.len > 0
    if shortPaths.len == 1:
        return shortPaths[0]

    shortPaths.sort(cmpDest)
    shortPaths = shortPaths.filterIt(it.dest == shortPaths[0].dest)

    assert shortPaths.len > 0
    if shortPaths.len == 1:
        return shortPaths[0]

    shortPaths.sort(cmpFirstMove)
    return shortPaths[0]

proc move(u: Unit, s: State) =
    var dests = initSet[Point]()
    for tg in u.getAllTargets(s):
        for n in s.reachableNeighbors(tg.loc):
            dests.incl n
    if dests.len == 0:
        return
    
    let paths = bfs(s, u.loc, dests)
    if paths.len == 0:
        return

    let move = selectPath(paths)[1]
    assert dist(u.loc, move) == 1
    u.loc = move

func getTargetsInRange(u: Unit, s: State): seq[Unit] =
    result = s.units.filterIt(
        it.isAlive and
        it.kind != u.kind and
        dist(u.loc, it.loc) == 1)

proc attack(attacker: Unit, target: Unit) =
    assert attacker.kind != target.kind
    assert attacker.isAlive() and target.isAlive()
    assert dist(attacker.loc, target.loc) == 1
    target.hp -= attacker.ap

proc takeTurn(u: Unit, state: State): TurnResult =
    let allTargets = u.getAllTargets(state)

    if allTargets.len == 0:
        return EndCombat

    var targetsInRange = u.getTargetsInRange(state)
    if targetsInRange.len == 0:
        u.move(state)
        targetsInRange = u.getTargetsInRange(state)

    if targetsInRange.len > 0:
        targetsInRange.sort(cmpTargets)
        u.attack(targetsInRange[0])
    
    return NoResult

func `$`(t: TileKind): string =
    case t:
        of Wall:
            result = "#"
        of Open:
            result = "."

proc show(s: State) =
    var lines: seq[string]
    for r in s.grid:
        lines.add(r.map(`$`).join(""))

    var uchar: char
    for u in s.units.filter(isAlive):
        lines[u.loc.y][u.loc.x] = ($u.kind)[0]
    
    for line in lines:
        echo line

proc playGame(state: State): (int, int) =
    var roundsPlayed = 0
    while roundsPlayed < 1000:
        echo ""
        echo roundsPlayed
        show state

        state.units.sort cmpReading
        for u in state.units:
            if not u.isAlive:
                continue
            
            if u.takeTurn(state) == EndCombat:
                let totalHp = state.units
                    .filter(isAlive)
                    .mapIt(it.hp)
                    .foldl(a+b)
                echo state.units
                    .filter(isAlive)
                    .mapIt(it.hp)
                return (roundsPlayed, totalHp)
        inc roundsPlayed

let state = readFile("./day15_example.txt").parseState()
let (roundsPlayed, totalHp) = playGame(state)
echo roundsPlayed, ", ", totalHp
echo roundsPlayed*totalHp