import std/strutils

import std/sequtils

import std/algorithm

import utils

type Pattern = SeqGrid[char]

func parseInput(txt: string): seq[Pattern] =
  let blocks = txt.strip.split("\n\n")
  for blk in blocks:
    var g: SeqGrid[char]
    for line in blk.strip.splitlines:
      g.add line.toSeq
    result.add g

#let input = readFile("input/day13_example.txt").parseInput
let input = readFile("input/day13_input.txt").parseInput

func checkVSym(g: Pattern; before: Natural): bool =
  let
    xhigh = g[0].high
    symHigh = min(before, xhigh - before + 1)
  for row in g:
    for i in 0..symHigh:
      if row[before - i] != row[before + i - 1]:
        return false
  result = true

func checkHSym(g: Pattern; before: Natural): bool =
  let
    yhigh = g.high
    symHigh = min(before, yhigh - before + 1)
  for x in 0..g[0].high:
    for i in 1..symHigh:
      if g[before - i][x] != g[before + i - 1][x]:
        return false
  result = true

let pt1 =
  block:
    var s = 0
    for pat in input:
      for pos in 1..pat.high:
        if checkHSym(pat, pos):
          s.inc 100 * pos
      for pos in 1..pat[0].high:
        if checkVSym(pat, pos):
          s.inc pos
    s

echo pt1

# Part 2

func splitColumns(g: Pattern; before: Natural): array[2, Pattern] =
  let
    xhigh = g[0].high
    numCols = min(before, xhigh - before + 1)
    leftCols = (before - numCols)..<before
    rightCols = before..<(before + numCols)
  result[0] = g.columns(leftcols)
  result[1] = g.columns(rightcols)

func flipColumns(g: Pattern): Pattern =
  result = g
  let w = g[0].high
  for x in 0..g[0].high:
    for y in 0..g.high:
      result[(w - x, y)] = g[(x, y)]

func splitRows(g: Pattern; before: Natural): array[2, Pattern] =
  let
    yHigh = g.high
    numRows = min(before, yhigh - before + 1)
    upperRows = (before - numRows)..<before
    lowerRows = before..<(before + numRows)
  result[0] = g[upperRows]
  result[1] = g[lowerRows]

func flipRows(g: Pattern): Pattern =
  g.reversed

func diff(a, b: Pattern): seq[Vector] =
  for v in a.locs:
    if a[v] != b[v]:
      result.add v

func findSmudge(pat: Pattern): int =
  for col in 1..pat[0].high:
    var parts = pat.splitColumns(col)
    parts[1] = flipColumns parts[1]
    let diffs = diff(parts[0], parts[1])
    if diffs.len == 1:
      return col

  for row in 1..pat.high:
    var parts = pat.splitRows(row)
    parts[1] = flipRows parts[1]
    let diffs = diff(parts[0], parts[1])
    if diffs.len == 1:
      return row * 100

let pt2 =
  block:
    var s = 0
    for pat in input:
      let patScore = findSmudge pat
      assert patScore > 0
      s.inc patScore
    s
echo pt2
