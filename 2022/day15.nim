import ./utils
import std/tables
import std/strutils
import std/sets

type
  SensorReport = OrderedTable[Vector, Vector]

  HLine = object
    y, xa, xb: int

const example = false
when example:
  const
    fname = "./input/day15_example.txt"
    part1Row = 10
    part2MaxCoord = 20
else:
  const
    fname = "./input/day15_input.txt"
    part1Row = 2_000_000
    part2MaxCoord = 4_000_000

func parseInput(text: string): SensorReport =
  for line in text.strip.splitLines:
    let ints = line.getInts
    assert ints.len == 4

    let
      sensor = (ints[0], ints[1])
      beacon = (ints[2], ints[3])
    assert sensor notin result
    result[sensor] = beacon

func part1(rep: SensorReport, targetRow: int): HashSet[Vector] =
  for (sensor, beacon) in rep.pairs:
    assert sensor != beacon
    let beaconDist = manhattan(beacon, sensor)
    for y in -beaconDist .. beaconDist:
      if (sensor.y + y) != targetRow:
        continue
      let xDist = beaconDist - abs(y)
      for x in -xDist .. xDist:
        let v = sensor + (x, y)
        assert manhattan(v, sensor) <= beaconDist
        if v != beacon:
          result.incl v

func contains(line: HLine, x: int): bool =
  x in line.xa .. line.xb

func contains(outLine, inLine: HLine): bool =
  inLine.y == outLine.y and inLine.xa in outLine and inLine.xb in outLine

func `-`(lna, lnb: HLine): seq[HLine] =
  doAssert lna.y == lnb.y
  if lna in lnb:
    discard
  elif lnb.xa notin lna and lnb.xb notin lna:
    result.add lna
  elif lnb.xa in lna and lnb.xb >= lna.xb:
    result.add HLine(y: lna.y, xa: lna.xa, xb: (lnb.xa - 1))
  elif lnb.xb in lna and lnb.xa <= lna.xa:
    result.add HLine(y: lna.y, xa: (lnb.xb + 1), xb: lna.xb)
  elif lnb.xa > lna.xa and lnb.xb < lna.xb:
    result.add HLine(y: lna.y, xa: lna.xa, xb: (lnb.xa - 1))
    result.add HLine(y: lna.y, xa: (lnb.xb + 1), xb: lna.xb)

  for ln in result:
    assert ln.xb >= ln.xa

func subtractAll(allLines: seq[HLine], sub: HLine): seq[HLine] =
  for ln in allLines:
    result.add(ln - sub)

func findNoBeaconLines(rep: SensorReport, maxCoord: int): seq[seq[HLine]] =
  var allRowLines = newSeqOfCap[seq[HLine]](maxCoord + 1)
  for y in 0 .. maxCoord:
    allRowLines.add @[HLine(y: y, xa: 0, xb: maxCoord)]

  for (sensor, beacon) in rep.pairs:
    assert sensor != beacon
    let beaconDist = manhattan(beacon, sensor)
    for yDist in -beaconDist .. beaconDist:
      let y = sensor.y + yDist
      if y notin (0 .. maxCoord):
        continue
      let
        xDist = beaconDist - abs(yDist)
        line = HLine(y: y, xa: (sensor.x - xDist), xb: (sensor.x + xDist))
      allRowLines[y] = subtractAll(allRowLines[y], line)
  result = allRowLines

func tuningFrequency(v: Vector): int =
  v.x * 4_000_000 + v.y

func part2(rep: SensorReport, maxCoord: int): int =
  let noBeaconLines = findNoBeaconLines(rep, maxCoord)
  for (y, rowLines) in noBeaconLines.pairs:
    if rowLines.len > 0:
      let ln = rowLines[0]
      doAssert rowLines.len == 1
      doAssert ln.xa == ln.xb
      doAssert ln.y == y
      return (ln.xa, ln.y).tuningFrequency

let input = readFile(fname).parseInput

echo part1(input, part1Row).card
echo part2(input, part2MaxCoord)
