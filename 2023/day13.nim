import std/strutils

import std/sequtils

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
