import utils
import std/sequtils

#const input = "16,1,2,0,4,2,7,1,2,14".getInts
let input = readFile("./input/day07_input.txt").getInts

func evalFuel1(positions: seq[int], moveTo: int): int =
  for p in positions:
    result.inc (p - moveTo).abs

func evalFuel2(positions: seq[int], moveTo: int): int =
  for p in positions:
    let dist = (p - moveTo).abs
    result.inc((dist * (dist + 1)) div 2)

type FF = proc(p: seq[int], m: int): int

func findAlignment(positions: seq[int], fuelfun: FF): tuple[fuel, pos: int] =
  result.fuel = int.high
  for candidate in 0 .. positions.max:
    let candidateFuel: int = fuelfun(positions, candidate)
    if candidateFuel < result.fuel:
      result.fuel = candidateFuel
      result.pos = candidate

let
  alignResult = input.findAlignment(evalFuel1)
  pt1 = alignResult.fuel
echo pt1
doAssert pt1 == 355989

let
  alignResultPt2 = input.findAlignment(evalFuel2)
  pt2 = alignResultPt2.fuel
echo pt2
doAssert pt2 == 102245489
