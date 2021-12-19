
import std/strutils
import std/strformat
import std/os

type SnailFishNumberKind = enum sfPair, sfLit

type SnailFishNumber = ref object
  case kind: SnailFishNumberKind
  of sfLit:
    val: int
  of sfPair:
    a, b: SnailFishNumber

type SnailFishParser = object
  tokens: string
  cur: int

const digit = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}

proc advance(p: var SnailFishParser) = p.cur.inc
func peek(p: SnailFishParser): char = p.tokens[p.cur]
func prev(p: SnailFishParser): char = p.tokens[p.cur - 1]
func isFinished(p: SnailFishParser): bool = p.cur > p.tokens.high

type GvNodeId = distinct string

proc `$`(i: GvNodeId): string = i.string

proc inc(id: var GvNodeId) =
  let s = id.string
  if s[1] < 'z':
    id = (s[0] & s[1].succ).GvNodeId
  else:
    id = (s[0].succ & 'a').GvNodeId

proc toGraphViz(n: SnailFishNumber, fname: string) =
  let f = open(fname, fmWrite)
  defer: f.close
  f.writeLine "digraph G {"

  var id = "aa".GvNodeId
  var stack: seq[tuple[n: SnailFishNumber, id: GvNodeId]]
  stack.add (n, id)
  while stack.len > 0:
    let cur = stack.pop
    case cur.n.kind:
    of sfLit:
      f.writeLine fmt"  {cur.id} [label={cur.n.val}, fillcolor=gold, style=filled]"
    of sfPair:
      id.inc
      f.writeLine fmt"  {cur.id} -> {id}"
      stack.add (cur.n.a, id)

      id.inc
      f.writeLine fmt"  {cur.id} -> {id}"
      stack.add (cur.n.b, id)
  f.writeLine("}")

proc match(p: var SnailFishParser, c: char): bool =
  if p.isFinished:
    result = false
  elif p.peek == c:
    p.advance
    result = true
  else:
    result = false

proc match(p: var SnailFishParser, s: set[char]): bool =
  if p.isFinished:
    result = false
  elif p.peek in s:
    p.advance
    result = true
  else:
    result = false

proc pair(p: var SnailFishParser): SnailFishNumber

proc primary(p: var SnailFishParser): SnailFishNumber =
  if p.match(digit):
    result = SnailFishNumber(kind: sfLit, val: parseInt($p.prev))
  elif p.match '[':
    result = p.pair()
    doAssert p.match ']'
  else:
    doAssert false

proc pair(p: var SnailFishParser): SnailFishNumber =
  result = p.primary()
  if p.match ',':
    let right = p.primary()
    result = SnailFishNumber(kind: sfPair, a: result, b: right)

proc parseSf(s: string): SnailFishNumber =
  let tokens = s.strip().replace(" ", "")
  var parser = SnailFishParser(tokens: tokens, cur: 0)
  result = parser.pair()

when isMainModule:
  let n = commandLineParams()[0].parseSf
  n.toGraphViz commandLineParams()[1]

