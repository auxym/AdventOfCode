import std/sets
import std/strutils
import std/sequtils
import regex

type Vector3d = array[3, int]

type Cuboid = object
  action: bool
  xslice: Slice[int]
  yslice: Slice[int]
  zslice: Slice[int]

func parseInput(s: string): seq[Cuboid] =
  const linepat = re"(on|off) x=(-?\d+)\.\.(-?\d+),y=(-?\d+)\.\.(-?\d+),z=(-?\d+)\.\.(-?\d+)"
  var m: RegexMatch
  for line in s.strip().splitLines:
    doAssert line.find(linepat, m)
    var c: Cuboid
    c.action = m.group(0, line)[0] == "on"

    let sliceInts = toSeq(1..6).mapIt(m.group(it, line)[0].parseInt)
    c.xslice = sliceInts[0] .. sliceInts[1]
    c.yslice = sliceInts[2] .. sliceInts[3]
    c.zslice = sliceInts[4] .. sliceInts[5]

    result.add c

func isInInit(c: Cuboid): bool =
  c.xslice.a >= -50 and c.xslice.b <= 50 and
  c.yslice.a >= -50 and c.yslice.b <= 50 and
  c.zslice.a >= -50 and c.zslice.b <= 50

func apply(s: var HashSet[Vector3d], c: Cuboid) =
  for i in c.xslice:
    for j in c.yslice:
      for k in c.zslice:
        if c.action:
          s.incl [i, j, k]
        else:
          s.excl [i, j, k]

let cuboids = readFile("./input/day22_input.txt").parseInput

var reboot: HashSet[Vector3d]
for c in cuboids:
  if c.isInInit:
    reboot.apply c
echo reboot.len
