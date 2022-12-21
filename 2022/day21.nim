import std/parseutils
import std/strutils
import std/tables

type
  NodeKind = enum Monkey, Literal, Expression

  Operation = enum opInvalid, opAdd, opSubstract, opDivide, opMult

  Node = ref object
    case kind: NodeKind
    of Monkey:
      name: string
    of Literal:
      intval: int
    of Expression:
      a, b: Node
      op: Operation

func terminal(text: string): Node =
  new result
  var i: int
  if text.parseInt(i) == text.len:
    result.kind = Literal
    result.intval = i
  else:
    result.kind = Monkey
    result.name = text

func expression(tokens: seq[string]): Node =
  result = terminal(tokens[0])

  if tokens.len > 1:
    assert tokens[1].len == 1
    assert tokens.len == 3
    result = block:
      var tmp = new Node
      tmp = Node(kind: Expression, a: result)
      tmp
    result.op = case tokens[1][0]:
      of '+': opAdd
      of '-': opSubstract
      of '*': opMult
      of '/': opDivide
      else: opInvalid
    assert result.op != opInvalid
    result.b = terminal(tokens[2])

func parseInput(text: string): Table[string, Node] =
  for line in text.strip.splitLines:
    let parts = line.strip.split(": ")
    assert parts.len == 2
    assert parts[0] notin result
    result[parts[0]] = parts[1].splitWhitespace.expression

func evalOperation(op: Operation, a, b: int): int =
  doAssert op != opInvalid
  result = case op:
    of opInvalid: 0
    of opAdd: a + b
    of opMult: a * b
    of opDivide: a div b
    of opSubstract: a - b

let input = readFile("./input/day21_input.txt").parseInput

proc eval(n: Node): int =
  result = case n.kind:
  of Literal:
    n.intval
  of Monkey:
    eval(input[n.name])
  of Expression:
    evalOperation(n.op, eval(n.a), eval(n.b))

# Part 1
echo eval Node(kind: Monkey, name: "root")
