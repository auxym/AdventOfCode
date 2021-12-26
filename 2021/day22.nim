import std/sets
import std/strutils
import std/sequtils
import regex

type Vector3d = array[3, int]

type Cuboid = object
  xslice: Slice[int]
  yslice: Slice[int]
  zslice: Slice[int]

type Action = enum on, off

type Instruction = object
  region: Cuboid
  action: Action

func parseInput(s: string): seq[Instruction] =
  const linepat = re"(on|off) x=(-?\d+)\.\.(-?\d+),y=(-?\d+)\.\.(-?\d+),z=(-?\d+)\.\.(-?\d+)"
  var m: RegexMatch
  for line in s.strip().splitLines:
    doAssert line.find(linepat, m)
    var ins: Instruction
    ins.action = parseEnum[Action] m.group(0, line)[0]

    let sliceInts = toSeq(1..6).mapIt(m.group(it, line)[0].parseInt)
    ins.region.xslice = sliceInts[0] .. sliceInts[1]
    ins.region.yslice = sliceInts[2] .. sliceInts[3]
    ins.region.zslice = sliceInts[4] .. sliceInts[5]

    result.add ins

func isInInit(c: Cuboid): bool =
  c.xslice.a >= -50 and c.xslice.b <= 50 and
  c.yslice.a >= -50 and c.yslice.b <= 50 and
  c.zslice.a >= -50 and c.zslice.b <= 50

func apply(s: var HashSet[Vector3d], ins: Instruction) =
  for i in ins.region.xslice:
    for j in ins.region.yslice:
      for k in ins.region.zslice:
        case ins.action:
        of on:
          s.incl [i, j, k]
        of off:
          s.excl [i, j, k]

let instructions = readFile("./input/day22_input.txt").parseInput

block part1:
  var reboot: HashSet[Vector3d]
  for ins in instructions:
    if ins.region.isInInit:
      reboot.apply ins
  let pt1 = reboot.len
  echo pt1
  doAssert pt1 == 644257

# Part 2

func volume(c: Cuboid): int =
  c.xslice.len * c.yslice.len * c.zslice.len

func intersection(a, b: Slice[int]): Slice[int] =
  result.a =  max(a.a, b.a)
  result.b =  min(a.b, b.b)
  # This will result in a "negative" slice (eg 8..2) if there is no intersection
  # This is OK since `len` on a negative slice is 0, so 0 volume

func intersection(a, b: Cuboid): Cuboid =
  result.xslice = intersection(a.xslice, b.xslice)
  result.yslice = intersection(a.yslice, b.yslice)
  result.zslice = intersection(a.zslice, b.zslice)

func combine(s: seq[Instruction]): int =
  # This was an idea I had but couldn't convince myself it would work.
  # I still can't but someone on reddit told me it would :)
  var
    positive: seq[Cuboid]
    negative: seq[Cuboid]
  for ins in s:
    var
      newPositive: seq[Cuboid]
      newNegative: seq[Cuboid]

    for pos in positive:
      let x = intersection(ins.region, pos)
      if x.volume > 0:
        newNegative.add x
    for neg in negative:
      let x = intersection(ins.region, neg)
      if x.volume > 0:
        newPositive.add x

    if ins.action == on:
      positive.add ins.region

    positive.add newPositive
    negative.add newNegative

  result = positive.map(volume).foldl(a + b) - negative.map(volume).foldl(a + b)

block part2:
  let pt2 = combine instructions
  echo pt2
