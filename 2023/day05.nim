import std/strutils

import std/sequtils

import utils

type MapEntry = object
  srcRange: Slice[Natural]
  offset: int

type AlmanacMap = object
  entries: seq[MapEntry]

type Almanac = object
  seeds: seq[Natural]
  maps: seq[AlmanacMap]

func parseInput(txt: string): Almanac =
  let blocks = txt.strip.split("\n\n")
  result.seeds = blocks[0].getInts.mapIt(it.Natural)

  for i in 1 .. blocks.high:
    let lines = blocks[i].strip.splitLines
    var amap: AlmanacMap

    for j in 1 .. lines.high:
      let parts = lines[j].getInts
      assert parts.len == 3
      amap.entries.add MapEntry(
        srcRange: parts[1].Natural ..< (parts[1] + parts[2]).Natural,
        offset: parts[0] - parts[1]
      )

    result.maps.add amap

func lookup(map: AlmanacMap, val: Natural): Natural =
  for ent in map.entries:
    if val in ent.srcRange:
      return val + ent.offset
  result = val

func lookupSeedLocation(alm: Almanac, seed: Natural): Natural =
  result = seed
  for map in alm.maps:
    result = map.lookup result

proc showAlmanac(almanac: Almanac) =
  echo "seeds: ", almanac.seeds
  for map in almanac.maps:
    echo "\nMap"
    for ent in map.entries:
      echo "source: ", ent.srcRange, " offset: ", ent.offset

let almanac = readFile("./input/day05_input.txt").parseInput

var pt1 = int.high
for seed in almanac.seeds:
  let loc = almanac.lookupSeedLocation seed
  if loc < pt1: pt1 = loc

echo pt1
