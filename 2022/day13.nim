import std/strutils
import std/sequtils
import std/algorithm

type
  LexerState = object
    text: string
    cur: int
    start: int

  TokenKind = enum LBracket, RBracket, Comma, IntLit, Eof

  Token = object
    kind: TokenKind
    text: string

  NodeKind = enum nkList, nkIntLit

  Node = ref object
    flag: int # divider flag for part 2
    case kind: NodeKind
    of nkList:
      children: seq[Node]
    of nkIntLit:
      intVal: int

  ParserState = object
    tokens: seq[Token]
    cur: int


func peek(lexer: LexerState): char = lexer.text[lexer.cur]
func isAtEnd(lexer: LexerState): bool = lexer.cur > lexer.text.high

proc advance(lexer: var LexerState): char =
  result = lexer.peek
  lexer.cur.inc

proc match(lexer: var LexerState, expected: char): bool =
  if not lexer.isAtEnd and lexer.peek == expected:
    discard lexer.advance
    result = true

func getToken(lexer: LexerState, kind: TokenKind): Token =
  Token(kind: kind, text: lexer.text[lexer.start ..< lexer.cur])

proc number(lexer: var LexerState): Token =
  while lexer.peek in Digits:
    discard lexer.advance
  result = lexer.getToken(IntLit)

func scan(text: string): seq[Token] =
  var lexer = LexerState(text: text, cur: 0)
  while not lexer.isAtEnd:
    lexer.start = lexer.cur
    let c = lexer.advance
    case c:
    of '[':
      result.add lexer.getToken(LBracket)
    of ']':
      result.add lexer.getToken(RBracket)
    of ',':
      result.add lexer.getToken(Comma)
    of Digits:
      result.add lexer.number()
    else:
      doAssert false # lex error

func isAtEnd(parser: ParserState): bool = parser.cur > parser.tokens.high

func peek(parser: ParserState): Token = parser.tokens[parser.cur]

func previous(parser: ParserState): Token = parser.tokens[parser.cur - 1]

proc advance(parser: var ParserState): Token =
  result = parser.tokens[parser.cur]
  parser.cur.inc

proc match(parser: var ParserState, expected: TokenKind): bool =
  if not parser.isAtEnd and parser.peek.kind == expected:
    result = true
    discard parser.advance

func primary(parser: var ParserState): Node

func list(parser: var ParserState): Node =
  new result
  result.kind = nkList
  while not (parser.isAtEnd or (parser.peek.kind == RBracket)):
    result.children.add parser.primary
    if not parser.match(Comma):
      break
  doAssert parser.match RBracket

func primary(parser: var ParserState): Node =
  if parser.match(IntLit):
    new result
    result = Node(kind: nkIntLit, intval: parser.previous.text.parseInt)

  elif parser.match(LBracket):
    result = parser.list

  else:
    doAssert false

func parse(tokens: seq[Token]): Node =
  var parser = ParserState(tokens: tokens, cur: 0)
  result = parser.primary

func parse(text: string): Node =
  let tokens = scan text
  result = parse tokens

func treeRepr(node: Node, idt: int = 0): string =
  result.add repeat(' ', idt)
  case node.kind:
  of nkIntLit:
    result.add $node.intVal
  of nkList:
    result.add "List"
    for c in node.children:
      result.add "\n"
      result.add c.treeRepr(idt + 2)

type Input = seq[array[2, Node]]

func parseInput(text: string): Input =
  for pair in text.strip.split("\n\n"):
    let lines = pair.splitLines
    assert lines.len == 2
    result.add [lines[0].parse, lines[1].parse]

func cmp(a, b: Node): int =
  if a.kind == nkIntLit and b.kind == nkIntLit:
    return cmp(a.intval, b.intval)

  elif a.kind == nkList and b.kind == nkList:
    var cur = -1
    while true:
      cur.inc
      if cur > a.children.high:
        if cur > b.children.high:
          return 0
        else:
          return -1
      elif cur > b.children.high:
        return 1

      let childrenCmpResult = cmp(a.children[cur], b.children[cur])
      if childrenCmpResult == 0:
        continue
      else:
        return childrenCmpResult

  elif a.kind == nkList and b.kind == nkIntLit:
    var tmp = new Node
    tmp.kind = nkList
    tmp.children.add b
    return cmp(a, tmp)

  elif a.kind == nkIntLit and b.kind == nkList:
    var tmp = new Node
    tmp.kind = nkList
    tmp.children.add a
    return cmp(tmp, b)

func part1(inp: Input): int =
  for (idx, pair) in inp.pairs:
    if cmp(pair[0], pair[1]) < 0:
      #debugEcho idx + 1
      result.inc (idx + 1)

#let input = readFile("./input/day13_example.txt").parseInput
let input = readFile("./input/day13_input.txt").parseInput

echo part1(input)

# Part 2 NOT WORKING YET

func part2(inp: Input): int =
  let dividers = """
  [[2]]
  [[6]]
  """.strip.splitLines.mapIt(it.strip.parse)
  assert dividers.len == 2
  dividers[0].flag = 2
  dividers[1].flag = 6

  let sortedPackets = block:
    var t: seq[Node]
    for pair in inp:
      for packet in pair:
        t.add packet
    for packet in dividers:
      t.add packet
    sort t
    t

  result = 1
  for (i, packet) in sortedPackets.pairs:
    if packet.flag == 2:
      result = result * (i + 1)
    elif packet.flag == 6:
      result = result * (i + 1)

echo part2(input)
