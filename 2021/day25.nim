import std/strutils

type CucumberMap = seq[string]

func step(m: CucumberMap): (CucumberMap, int) =
  let
    numRows = m.len
    numCols = m[0].len
  var
    newMap = m
    changes = 0

  for (i, line) in m.pairs:
    for (j, tile) in line.pairs:
      if tile == '>':
        let jdest = (j + 1) mod numCols
        if m[i][jdest] == '.':
          newMap[i][jdest] = '>'
          newMap[i][j] = '.'
          changes.inc

  let tmp = newMap
  for (i, line) in tmp.pairs:
    for (j, tile) in line.pairs:
      if tile == 'v':
        let idest = (i + 1) mod numRows
        if tmp[idest][j] == '.':
          newMap[idest][j] = 'v'
          newMap[i][j] = '.'
          changes.inc

  result = (newMap, changes)

let input = readFile("./input/day25_input.txt").strip.splitLines
var
  numChanges = int.high
  newMap = input
  i = 0

while numChanges > 0:
  (newMap, numChanges) = newMap.step
  i.inc

echo i
