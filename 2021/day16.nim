import std/strutils
import std/sequtils

const limbsz = 32

type BitSeq = object
  limbs: seq[uint32]
  len: int

type BitsNodeKind = enum nkLiteral, nkOperator

type BitsNode = ref object
  version: uint
  id: uint
  case kind: BitsNodeKind
  of nkLiteral:
    value: uint
  of nkOperator:
    children: seq[BitsNode]
    op: uint

type BitsParser = object
  bits: BitSeq
  cur: Natural

func `[]`(bs: BitSeq, i: Natural): uint =
  let
    limbIdx = i div limbsz
    shift = (limbsz - (i mod limbsz) - 1)
    mask: uint32 = 1'u32 shl shift
  result = ((bs.limbs[limbIdx] and mask) shr shift).uint

func `[]`(bs: BitSeq, slc: Slice[int]): uint =
  doAssert slc.a - slc.b + 1 <= 64
  let
    startLimb = slc.a div 32
    endLimb = slc.b div 32

  for i in startLimb..endLimb:
    if i == startLimb:
      let
        numBits = limbsz - (slc.a mod limbsz)
        mask = (1'u shl numBits) - 1
      result = bs.limbs[i] and mask
      if i == endLimb:
        let shift = limbsz - (slc.b mod limbsz) - 1
        result = result shr shift

    elif i == endLimb:
      let
        numbits = (slc.b mod limbsz) + 1
        mask = uint32.high shl (limbsz - numbits)
      result = (result shl numbits) or ((bs.limbs[i] and mask) shr (limbsz - numbits))

    else:
      result = (result shl limbsz) or bs.limbs[i]

proc consume(ps: var BitsParser, n: Natural): uint =
  result = ps.bits[ps.cur.int ..< ps.cur + n]
  ps.cur.inc n

proc literal(ps: var BitsParser): uint =
  const
    stopMask = 0b10000
    valMask = 0b1111
  var stop = false
  while not stop:
    let e = ps.consume(5)
    result = (result shl 4) or (e and valmask)
    stop = (e and stopMask) == 0

proc packet(ps: var BitsParser): BitsNode

proc opChildren(ps: var BitsParser): seq[BitsNode] =
  let lengthType = ps.consume(1)
  if lengthType == 0:
    let
      childrenNumBits = ps.consume(15).int
      psEndPos = ps.cur.int + childrenNumBits
    while ps.cur < psEndPos:
      result.add ps.packet()
    doAssert ps.cur == psEndPos

  elif lengthType == 1:
    let numChildren = ps.consume(11).int
    while result.len < numChildren:
      result.add ps.packet()

proc packet(ps: var BitsParser): BitsNode =
  let version = ps.consume(3)
  let kind = ps.consume(3)
  if kind == 4:
    result = BitsNode(
      version: version,
      kind: nkLiteral,
      value: ps.literal()
    )
  else:
    result = BitsNode(
      version: version,
      kind: nkOperator,
      children: ps.opChildren(),
      op: kind
    )

proc toBitSeq(s: string): BitSeq =
  let s = s.strip()
  for i in countup(0, s.high, 8):
    var sub = s[i..min([i + 7, s.high])]
    result.len.inc (sub.len * 4)

    while sub.len < 8:
      sub = sub & "0"

    result.limbs.add sub.parseHexInt.uint32

proc parseBits(s: string): BitsNode =
  var ps = BitsParser(cur:0, bits: s.toBitSeq)
  result = ps.packet()

func versionSum(p: BitsNode): int =
  var stack: seq[BitsNode]
  stack.add p
  while stack.len > 0:
    let c = stack.pop
    result.inc c.version.int
    if c.kind == nkOperator:
      for other in c.children:
        stack.add other

func eval(node: BitsNode): uint =
  if node.kind == nkLiteral:
    result = node.value
  else:
    let cvals = node.children.map(eval)
    result = case node.op:
    of 0:
      cvals.foldl(a+b)
    of 1:
      cvals.foldl(a*b)
    of 2:
      cvals.min
    of 3:
      cvals.max
    of 5:
      if cvals[0] > cvals[1]: 1 else: 0
    of 6:
      if cvals[0] < cvals[1]: 1 else: 0
    of 7:
      if cvals[0] == cvals[1]: 1 else: 0
    else:
      doAssert false
      uint.high

let transmission = readFile("./input/day16_input.txt").parseBits
echo transmission.versionSum
echo transmission.eval


# Unit tests

const dotest = false
when dotest:
  import std/unittest
  import std/strformat

  proc toBinStr(b: BitSeq): string =
    for limb in b.limbs:
      result = result & fmt"{limb:032b}"
    result = result[0 ..< b.len]

  func toBitSeq(s: seq[SomeInteger]): BitSeq =
    for e in s:
      result.limbs.add uint32(e)
      result.len.inc sizeof(int)

  suite "bitseq":
    test "single index":
      check:
        (@[0b10101111].toBitSeq)[24] == 1'u
        (@[0b10101111].toBitSeq)[25] == 0'u
        (@[0b10101111].toBitSeq)[0] == 0'u
        (@[0b10101111].toBitSeq)[31] == 1'u
        (@[0, 0b10101111].toBitSeq)[32+24] == 1'u
        (@[0, 0b10101111].toBitSeq)[32+25] == 0'u
        (@[0, 0b10101111].toBitSeq)[32+0] == 0'u
        (@[0, 0b10101111].toBitSeq)[32+31] == 1'u
    test "slice index":
      check:
        (@[0b10101111].toBitSeq)[24..27] == 0b1010.uint
        (@[0b10101111].toBitSeq)[28..31] == 0b1111.uint
        (@[0b10101111, 0].toBitSeq)[24..32] == 0b101011110.uint
        (@[0b10101111, uint32.high.int].toBitSeq)[24..32] == 0b101011111.uint
        (@[0b10101111, uint32.high.int].toBitSeq)[24..33] == 0b1010111111.uint
        (@[0b1010, 0, uint32.high.int].toBitSeq)[28..64] == (0b1010.uint shl 32) * 2 + 1

  suite "bitsparser":
    test "convert to bitseq":
      check:
        "D2FE28".toBitSeq.toBinStr == "110100101111111000101000"

    test "parse literal packet":
      let d2 = "D2FE28".parseBits
      check:
        d2.version == 6
        d2.kind == nkLiteral
        d2.value == 2021

    test "parse operator packet with type 0 length":
      let p = "38006F45291200".parseBits
      check:
        p.version == 1
        p.kind == nkOperator
        p.children.len == 2
        p.children[0].value == 10
        p.children[1].value == 20

    test "parse op with type 1 length":
      let p = "EE00D40C823060".parseBits
      check:
        p.version == 7
        p.kind == nkOperator
        p.children.len == 3
        p.children.mapIt(it.value.int) == @[1, 2, 3]
