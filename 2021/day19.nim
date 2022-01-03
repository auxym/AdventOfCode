# Runs in about 20 s on my i5-4310U laptop

import std/strutils
import std/sequtils
import std/strformat
import std/deques
import std/sets
import std/hashes
import std/tables
import std/random
import std/options

import arraymancer
import regex
import utils

randomize()

type ScanResult = object
  scannerId: int
  beacons: seq[Tensor[int]]

type Transform = object
  translation: Tensor[int]
  rotation: Tensor[int]

# Map A -> (B, transform from B to A)
# B.applyTransform(t) == A
type TransformTable = Table[int, seq[(int, Transform)]]

let eye = [[1, 0, 0],
            [0, 1, 0],
            [0, 0, 1]].toTensor()

iterator allRotations: Tensor[int] =
  let RX = [[1, 0, 0],
            [0, 0, -1],
            [0, 1, 0]].toTensor()
  let RY = [[0, 0, 1],
            [0, 1, 0],
            [-1, 0, 0]].toTensor()
  let RZ = [[0, -1, 0],
            [1, 0, 0],
            [0, 0, 1]].toTensor()

  let zOrient = @[eye, RX, RX * RX, RX * RX * RX, RY, RY * RY * RY]
  for z in zOrient:
    var r = z
    yield r
    for i in 0..2:
      r = RZ * r
      yield r

proc hash(v: Tensor[int]): Hash =
  for x in v:
    result = result !& x.hash
  result = !$result

proc parseInput(s: string): seq[ScanResult] =
  let chunks = s.strip().split("\n\n")
  for chunk in chunks:
    let lines = chunk.strip().splitLines()

    var m: RegexMatch
    doAssert lines[0].find(re"scanner (\d+)", m)
    let scannerId = m.group(0, lines[0])[0].parseInt

    var cur = newSeqOfCap[Tensor[int]](lines.len - 1)
    for line in lines[1..lines.high]:
      let ints = line.getInts
      assert ints.len == 3
      cur.add ints.toTensor().reshape(3, 1)
    result.add ScanResult(scannerId: scannerId, beacons: cur)

proc invert(t: Transform): Transform =
  result.rotation = t.rotation.transpose()
  result.translation = -(result.rotation * t.translation)

proc applyTransform(b: Tensor[int], t: Transform): Tensor[int] =
  (t.rotation * b) + t.translation

proc chain(a, b: Transform): Transform =
  result.rotation = b.rotation * a.rotation
  result.translation = (b.rotation * a.translation) + b.translation
  assert result.rotation.shape == @[3, 3]
  assert result.translation.shape == @[3, 1]

proc getTransform(map: TransformTable, src, target: int): Option[Transform] =
  var
    q = initDeque[(int, Transform)]()
    visited: HashSet[int]

  let noop = Transform(translation: zeros[int](3, 1), rotation: eye)
  if target == src:
    return noop.some
  q.addFirst (src, noop)

  # BFS
  while q.len > 0:
    let cur = q.popLast
    visited.incl cur[0]
    for (other, t) in map.getOrDefault(cur[0], @[]):
      if other in visited: continue
      let t2 = chain(cur[1], t)
      if other == target:
        return t2.some
      q.addFirst (other, t2)

  # No path found
  result = Transform.none

proc show(t: TransformTable) =
  for (k, v) in t.pairs:
    let dsts = v.mapIt($it[0]).join(", ")
    echo fmt"{k} -> ({dsts})"

proc findTransform(sca, scb: ScanResult): Option[Transform] =
  let aBeaconSet = sca.beacons.toHashSet
  for rot in allRotations():
    let bBeaconsRot = scb.beacons.mapIt(rot * it)

    # Props to someone on reddit for suggesting a randomized approach
    # 16 iterations = 99.91% probability of finding the translation it it exists
    for i in 1 .. 16:
      let translation = sca.beacons.sample - bBeaconsRot.sample
      let bBeaconsTrans = bBeaconsRot.mapIt(it + translation)
      if  (aBeaconSet * bBeaconsTrans.toHashSet).len >= 12:
        let t = Transform(rotation: rot, translation: translation)
        return t.some

proc matchScanners(scans: seq[ScanResult]): TransformTable =
  var foundPaths: HashSet[(int, int)]
  var remaining: HashSet[int]
  for s in scans:
    remaining.incl s.scannerId
  remaining.excl 0

  while remaining.len > 0:
    for scannerPair in scans.combinations(2):
      let
        sca = scannerPair[0]
        scb = scannerPair[1]

      if ((sca.scannerId notin remaining) and (scb.scannerId notin remaining)) or
        (sca.scannerId, scb.scannerId) in foundPaths:
          continue

      let tOpt = findTransform(sca, scb)
      if tOpt.isSome:
        let t = tOpt.get
        result.mgetOrPut(scb.scannerId, @[]).add (sca.scannerId, t)
        result.mgetOrPut(sca.scannerId, @[]).add (scb.scannerId, t.invert())
        foundPaths.incl (sca.scannerId, scb.scannerId)
        foundPaths.incl (scb.scannerId, sca.scannerId)
        #echo fmt"Found {sca.scannerId} <--> {scb.scannerId}"
        #echo fmt"4 -> 0: {result.getTransform(4, 0).isSome}"
        for k in toSeq(remaining):
          if result.getTransform(k, 0).isSome:
            remaining.excl k
        #echo remaining
        #result.show

proc getTransformsTo0(t: TransformTable): Table[int, Transform] =
  for k in t.keys:
    result[k] = t.getTransform(k, 0).get

proc countUniqueBeacons(scans: seq[ScanResult], tmap: Table[int, Transform]): int =
  #for (src, others) in matches.pairs:
    #let ostr = others.mapIt(it[0]).join(", ")
    #echo fmt"{src} -> ({ostr})"

  var ubeacons: HashSet[Tensor[int]]
  for scanner in scans:
    for b in scanner.beacons:
      ubeacons.incl b.applyTransform tmap[scanner.scannerId]
  result = ubeacons.len

let
  allScans = readFile("./input/day19_input.txt").parseInput
  matches = allScans.matchScanners
  t0map = matches.getTransformsTo0
echo allScans.countUniqueBeacons(t0map)

# Part 2

func manhattan3(a, b: Tensor[int]): int =
  abs(b[0, 0] - a[0, 0]) + abs(b[1, 0] - a[1, 0]) + abs(b[2, 0] - a[2, 0])

var maxDist = int.low
for scannerPair in allScans.combinations(2):
  let
    sca = scannerPair[0]
    scb = scannerPair[1]
    sca0 = zeros[int](3, 1).applyTransform(t0map[sca.scannerId])
    scb0 = zeros[int](3, 1).applyTransform(t0map[scb.scannerId])
    dist = manhattan3(sca0, scb0)
  if dist > maxDist: maxDist = dist
echo maxDist

when false:
  import std/unittest
  suite "unit tests":
    let RX = [[1, 0, 0],
              [0, 0, -1],
              [0, 1, 0]].toTensor()
    let RY = [[0, 0, 1],
              [0, 1, 0],
              [-1, 0, 0]].toTensor()

    test "rotation matrices":
      var mats: seq[Tensor[int]]
      for r in allRotations():
        check:
          r.transpose() * r == eye
          r * r.transpose() == eye
          r notin mats
        mats.add r

      check mats.len == 24

    test "inverse transform":
      let
        t1 = Transform(rotation: RX*RY, translation: [4, 7, -21].toTensor())
        t2 = t1.invert
        x = [19, -31, 47].toTensor
        y = x.applyTransform(t1)

      check:
        y.applyTransform(t2) == x
