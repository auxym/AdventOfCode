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

let inputTxt = """
Time:        53     83     72     88
Distance:   333   1635   1289   1532
"""

let inputRaces = parseInput inputTxt

func numWaysToBreakRecord(race: Race): Natural =
  for holdTime in 0 .. race.time:
    let dist = (race.time - holdTime) * holdTime
    if dist > race.recordDistance:
      inc result

let pt1 = inputRaces.map(numWaysToBreakRecord).foldl(a*b)
echo pt1

# Part 2
func parseInput2(txt: string): Race =
  let lines = txt.strip.splitLines.mapIt(it.replace(" ", ""))
  result.time = lines[0].getInts[0]
  result.recordDistance = lines[1].getInts[0]

let inputRace2 = parseInput2 inputTxt
let pt2 = numWaysToBreakRecord inputRace2
echo pt2
