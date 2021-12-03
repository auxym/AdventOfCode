import std/strutils
import std/sequtils

#let input = """
#00100
#11110
#10110
#10111
#10101
#01111
#00111
#11100
#10000
#11001
#00010
#01010
#""".strip.splitLines.mapIt(it.parseBinInt.uint)

let input = readFile("./input/day03_input.txt").strip().splitLines().mapIt(it.parseBinInt.uint)

const
  nbits = 12
  inputMask = (1'u shl nbits) - 1

type ColumnSums = array[nbits, Natural]

func sumByColumn(codes: seq[uint]): ColumnSums =
  for c in codes:
    for i in 0 ..< nbits:
      let mask = 1'u shl i
      if (mask and c) > 0: result[i].inc

func gammaRate(codes: seq[uint]): uint =
  let sums = sumByColumn(codes)
  for i in 0..sums.high:
    if sums[i] >= (codes.len - sums[i]):
      result = result or (1'u shl i)

let
  gamma = input.gammaRate
  epsilon = (not gamma) and inputMask

let powerConsumption = gamma * epsilon
doAssert powerConsumption == 3882564
echo powerConsumption

# Part 2

type GasRatingType = enum Oxygen, Co2

func findGasRating(codes: seq[uint], gas: GasRatingType): uint =
  var
    i = (nbits - 1) # first bit is lsb
    codesRemaining = codes

  while i >= 0:
    let mask = 1'u shl i
    let bitCrit = case gas:
      of Oxygen:
        gammaRate(codesRemaining) and mask
      of Co2:
        (not gammaRate(codesRemaining)) and mask

    codesRemaining = codesRemaining.filterIt((it and mask) == bitCrit)

    if codesRemaining.len == 1:
      return codesRemaining[0]

    dec i

let
  oxygenRating = input.findGasRating(Oxygen)
  co2Rating = input.findGasRating(Co2)
  lifeSupport = co2Rating * oxygenRating

echo lifeSupport
doAssert lifeSupport == 3385170