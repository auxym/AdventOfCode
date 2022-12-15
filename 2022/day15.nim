import ./utils
import std/tables
import std/strutils
import std/sets

type
  SensorReport = OrderedTable[Vector, Vector]

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

let
  input = readFile("./input/day15_input.txt").parseInput

const
  part1ExampleRow = 10
  part1Row = 2_000_000

echo part1(input, part1Row).card
