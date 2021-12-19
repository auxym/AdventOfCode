# Compile with --deepCopy:on
import std/strutils
import std/sequtils
import std/strformat
import utils

type SnailFishNumberKind = enum sfPair, sfLit

type GvNodeId = distinct string

type SnailFishNumber = ref object
  id: GvNodeId
  case kind: SnailFishNumberKind
  of sfLit:
    val: int
  of sfPair:
    a, b: SnailFishNumber

type SnailFishParser = object
  tokens: string
  cur: int

const digit = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}

func sf(x: int, id: GvNodeId = "zz".GvNodeId): SnailFishNumber =
  SnailFishNumber(kind: sfLit, val: x, id: id)

func isLit(n: SnailFishNumber): bool = n.kind == sfLit

func isLitPair(x: SnailFishNumber): bool =
  x.kind == sfPair and x.a.kind == sfLit and x.b.kind == sfLit

proc advance(p: var SnailFishParser) = p.cur.inc
func peek(p: SnailFishParser): char = p.tokens[p.cur]
func prev(p: SnailFishParser): char = p.tokens[p.cur - 1]
func isFinished(p: SnailFishParser): bool = p.cur > p.tokens.high

proc `$`(i: GvNodeId): string = i.string

proc inc(id: var GvNodeId) =
  let s = id.string
  if s[1] < 'z':
    id = (s[0] & s[1].succ).GvNodeId
  else:
    id = (s[0].succ & 'a').GvNodeId

proc assignIds(n: var SnailFishNumber) =
  var id = "aa".GvNodeId
  var stack: seq[SnailFishNumber]
  stack.add n
  while stack.len > 0:
    let cur = stack.pop
    cur.id = id
    id.inc
    if cur.kind == sfPair:
      stack.add cur.a
      stack.add cur.b

proc toGraphViz(n: SnailFishNumber, fname: string) =
  let f = open(fname, fmWrite)
  defer: f.close
  f.writeLine "digraph G {"

  var stack: seq[SnailFishNumber]
  stack.add n
  while stack.len > 0:
    let cur = stack.pop
    case cur.kind:
    of sfLit:
      f.writeLine &"  {cur.id} [label=\"{cur.id}:{cur.val}\", fillcolor=gold, style=filled]"
    of sfPair:
      f.writeLine fmt"  {cur.id} -> {cur.a.id}"
      f.writeLine fmt"  {cur.id} -> {cur.b.id}"
      stack.add cur.a
      stack.add cur.b
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
    if not p.match ']':
      raise newException(Exception, fmt"expected ']' at position {p.cur} but got {p.peek}")
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
  result.assignIds()

proc parseMany(s: string): seq[SnailFishNumber] =
  s.strip().splitLines.map(parseSf)

proc `$`(sf: SnailFishNumber): string =
  case sf.kind:
  of sfLit:
    $sf.val
  of sfPair:
    ["[", $sf.a, ",", $sf.b, "]"].join("")

func `+`(a, b: SnailFishNumber): SnailFishNumber =
  let
    a = deepCopy a
    b = deepCopy b
  result = SnailFishNumber(kind: sfPair, a: a, b: b)
  result.assignIds()

type ExplodeRes = object
  a, b: int
  flag: bool

proc addLeft(n: var SnailFishNumber, x: int) =
  case n.kind:
  of sfLit:
    n.val.inc x
  of sfPair:
    addLeft n.a, x

proc addRight(n: var SnailFishNumber, x: int) =
  case n.kind:
  of sfLit:
    n.val.inc x
  of sfPair:
    addRight n.b, x

proc explode(n: var SnailFishNumber, depth: int = 0): ExplodeRes =
  case n.kind:
  of sfLit:
    result = ExplodeRes(flag: false)
  of sfPair:
    # Left
    if depth < 3:
      result = explode(n.a, depth + 1)
    elif depth == 3 and n.a.isLitPair:
      result = ExplodeRes(a: n.a.a.val, b: n.a.b.val, flag: true)
      n.a = sf(0, n.a.id)

    if result.flag:
      addLeft n.b, result.b
      result.b = 0
      return

    # Right, if nothing on left exploded
    if depth < 3:
      result = explode(n.b, depth + 1)
    elif depth == 3 and n.b.isLitPair:
      result = ExplodeRes(a: n.b.a.val, b: n.b.b.val, flag: true)
      n.b = sf(0, n.b.id)

    if result.flag:
      addRight n.a, result.a
      result.a = 0

proc splitRec(n: var SnailFishNumber): tuple[m: SnailFishNumber, flag: bool] =
  case n.kind:
  of sfLit:
    if n.val >= 10:
      let v = n.val
      result.m = SnailFishNumber(
        kind: sfPair,
        a: (v div 2).sf,
        b: ((v div 2) + (v mod 2)).sf
      )
      result.flag = true
      return
    else:
      return (n, false)

  of sfPair:
    let (ma, aflag) = n.a.splitRec()
    if aflag:
      n.a = ma
      return (n, aflag)

    let (mb, bflag) = n.b.splitRec()
    if bflag:
      n.b = mb
      return (n, bflag)

    return (n, false)

proc split(n: var SnailFishNumber): bool =
  let (tmp, flag) = splitRec n
  n.assignIds()
  result = flag

proc reduce(n: var SnailFishNumber) =
  var action = true
  while action:
    action = false
    action = n.explode.flag
    if not action:
      action = n.split()

proc sum(allNums: seq[SnailFishNumber]): SnailFishNumber =
  result = allNums[0]
  for i in 1..allNums.high:
    result = result + allNums[i]
    result.reduce

func mag(n: SnailFishNumber): int =
  case n.kind:
  of sfLit:
    n.val
  of sfPair:
    3 * n.a.mag  + 2 * n.b.mag

let inputNumbers = readFile("./input/day18_input.txt").parseMany
echo inputNumbers.sum().mag()

# Part 2
var maxMag = int.low
for comb in inputNumbers.combinations(2):
  for orderedComb in @[comb, @[comb[1], comb[0]]]:
    let s = orderedComb.sum.mag
    if s > maxMag:
      maxMag = s
echo maxMag

# Unit tests

when false:
  import std/unittest

  suite "Snail fish":
    test "parse and stringify":
      check:
        $("[[[[1,1],[2,2]],[3,3]],[4,4]]".parseSf) == "[[[[1,1],[2,2]],[3,3]],[4,4]]"

    test "add no reduce":
      let a = "[[[[4,3],4],4],[7,[[8,4],9]]]".parseSf
      let b = "[1,1]".parseSf
      check:
        $(a+b) == "[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]"

    test "single explode":
      var n = "[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]".parseSf
      var n2 = "[[[[0,7],4],[7,[[8,4],9]]],[1,1]]".parseSf
      var n3 = "[[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]]".parseSf
      check:
        n.explode.flag == true
        $n == $n2

        n2.explode.flag == true
        $n2 == "[[[[0,7],4],[15,[0,13]]],[1,1]]"

        n3.explode.flag == true
        $n3 == "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]"

    test "single split":
      var n = SnailFishNumber(kind: sfPair, a: 5.sf, b: 11.sf)
      var n2 = SnailFishNumber(kind: sfPair, a: 12.sf, b: 1.sf)
      check:
        n.split ==  true
        n2.split == true
        $n == "[5,[5,6]]"
        $n2 == "[[6,6],1]"

    test "reduce":
      var n = "[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]".parseSf
      n.reduce()
      check:
        $n == "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]"

    test "Multiple additions":
      let all1 = """
      [1,1]
      [2,2]
      [3,3]
      [4,4]
      """.parseMany

      let all2 = """
      [1,1]
      [2,2]
      [3,3]
      [4,4]
      [5,5]
      """.parseMany

      let all3 = """
      [1,1]
      [2,2]
      [3,3]
      [4,4]
      [5,5]
      [6,6]
      """.parseMany

      let all4 = """
      [[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
      [7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
      [[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
      [[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]
      [7,[5,[[3,8],[1,4]]]]
      [[2,[2,2]],[8,[8,1]]]
      [2,9]
      [1,[[[9,3],9],[[9,0],[0,7]]]]
      [[[5,[7,4]],7],1]
      [[[[4,2],2],6],[8,7]]
      """.parseMany

      check:
        true
        $all1.sum() == "[[[[1,1],[2,2]],[3,3]],[4,4]]"
        $all2.sum() == "[[[[3,0],[5,3]],[4,4]],[5,5]]"
        $all3.sum() == "[[[[5,0],[7,4]],[5,5]],[6,6]]"
        $all4.sum() == "[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]"
        $all4[0..1].sum() == "[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]"

    test "magnitude":
      check:
        "[[1,2],[[3,4],5]]".parseSf.mag == 143
        "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]".parseSf.mag == 1384
        "[[[[1,1],[2,2]],[3,3]],[4,4]]".parseSf.mag == 445
        "[[[[3,0],[5,3]],[4,4]],[5,5]]".parseSf.mag == 791
        "[[[[5,0],[7,4]],[5,5]],[6,6]]".parseSf.mag == 1137
        "[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]".parseSf.mag == 3488
