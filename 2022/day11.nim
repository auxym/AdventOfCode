import std/strutils
import std/sequtils
import std/parseutils
import std/deques
import std/algorithm
import ./utils

type
  OperandKind = enum Lit, Old

  Operand = object
    case kind: OperandKind
    of Lit:
      intVal: int
    of Old:
      discard

  MonkeyOperation = object
    a, b: Operand
    op: char

  MonkeyData = object
    items: Deque[int]
    op: MonkeyOperation
    divisor: int
    targets: array[bool, Natural]
    inspectCount: int

func parseOperand(s: string): Operand =
  let stripped = s.strip
  result.kind = Lit
  if parseInt(stripped, result.intVal) < stripped.len:
    result.kind = Old
    assert stripped == "old"

func parseOperation(opStr: string): MonkeyOperation =
  let parts = opStr.splitWhitespace
  result.a = parts[0].parseOperand
  result.b = parts[2].parseOperand
  assert parts[1].len == 1
  result.op = parts[1][0]

func parseInput(s: string): seq[MonkeyData] =
  for mblock in s.strip.split("\n\n"):
    let lines = mblock.splitLines
    assert lines[0].getInts[0] == result.len
    var monkey: MonkeyData
    monkey.items = lines[1].split(':')[1].split(',').mapIt(it.strip.parseInt).toDeque
    monkey.op = parseOperation(lines[2].split('=')[1].strip)
    monkey.divisor = lines[3].getInts[0]
    monkey.targets = [
      lines[5].getInts[0].Natural,
      lines[4].getInts[0].Natural,
    ]
    result.add monkey

func exec(op: MonkeyOperation, old: int): int =
  let a: int = case op.a.kind
    of Old: old
    of Lit: op.a.intVal
  let b: int = case op.b.kind
    of Old: old
    of Lit: op.b.intVal
  case op.op:
    of '*': result = a * b
    of '+': result = a + b
    else: doAssert false

proc playRound(monkeys: var seq[MonkeyData]) =
  for i in 0 .. monkeys.high:
    while monkeys[i].items.len > 0:
      monkeys[i].inspectCount.inc
      var item = monkeys[i].items.popFirst
      item = monkeys[i].op.exec(item)
      item = item div 3
      let
        testRes = item mod (monkeys[i].divisor) == 0
        target = monkeys[i].targets[testRes]
      monkeys[target].items.addLast item

let input = readFile("./input/day11_input.txt").parseInput

func part1(allMonkeys: seq[MonkeyData]): int =
  var working = allMonkeys
  for i in 0 ..< 20:
    working.playRound
  var counts = working.mapIt(it.inspectCount)
  sort counts
  result = counts[^1] * counts[^2]

echo part1(input)
