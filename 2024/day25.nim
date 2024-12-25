import std/strutils
import std/enumerate
import std/algorithm
import std/math

type
  Schematic = array[5, 0..5]

  Input = object
    locks: seq[Schematic]
    keys: seq[Schematic]

func parseInput(s: string): Input =
  for blk in s.strip.split("\n\n"):
    let (lines, isKey) = block:
      var lines = blk.splitLines()
      var isKey = false
      if lines[0] == ".....":
        reverse lines
        isKey = true
      elif lines[0] != "#####":
        raise newException(ValueError, "Unexpected ID row")
      (lines, isKey)

    var schem: Schematic
    for ln in lines[1 .. ^1]:
      for (col, c) in enumerate(ln):
        if c == '#':
          inc schem[col]

    if isKey:
      result.keys.add schem
    else:
      result.locks.add schem

let input = readFile("./input/day25_input.txt").parseInput

func checkFit(lock, key: Schematic): bool =
  result = true
  for i in Schematic.low .. Schematic.high:
    if lock[i] + key[i] > 5: return false

func p1(input: Input): int =
  for lock in input.locks:
    for key in input.keys:
      if checkFit(lock, key): inc result

echo p1(input)
