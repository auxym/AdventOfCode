import std/strutils

import std/sequtils

import utils

# t = L - h
# v = h
# d = t * v = (L - h) * h = Lh - h**2

type Race = object
  time, recordDistance: Natural

func parseInput(txt: string): seq[Race] =
  let lines = txt.strip.splitLines
  for (time, dist) in zip(lines[0].getInts, lines[1].getInts):
    result.add Race(time: time, recordDistance: dist)

let inputRaces = """
Time:        53     83     72     88
Distance:   333   1635   1289   1532
""".parseInput

func numWaysToBreakRecord(race: Race): Natural =
  for holdTime in 0 .. race.time:
    let dist = (race.time - holdTime) * holdTime
    if dist > race.recordDistance:
      inc result

let pt1 = inputRaces.map(numWaysToBreakRecord).foldl(a*b)
echo pt1

# Part 2
