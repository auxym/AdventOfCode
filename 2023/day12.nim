import std/strutils

import std/sequtils

import utils

type ConditionRecord = object
  row: string
  checksum: seq[Natural]

type Input = seq[ConditionRecord]

func parseInput(txt: string): Input =
  for line in txt.strip.splitLines:
    let parts = line.split()
    result.add ConditionRecord(
        row: parts[0].strip, checksum: parts[1].getNaturalInts.mapIt(it.Natural)
      )

#let input = readFile("input/day12_example.txt").parseInput
let input = readFile("input/day12_input.txt").parseInput

func check2(rec: ConditionRecord): bool =
  var i = 0

  for rl in rec.checksum:
    var cur = 0
    while i <= rec.row.high and rec.row[i] == '.':
      inc i
    while i <= rec.row.high and rec.row[i] == '#':
      inc cur
      inc i
    if i <= rec.row.high and rec.row[i] == '?':
      return true
    if cur != rl:
      return false

  while i <= rec.row.high and rec.row[i] in {'.', '?'}:
    inc i
  result = i == rec.row.len

func isComplete(rec: ConditionRecord): bool =
  '?' notin rec.row

func repair(rec: ConditionRecord): seq[ConditionRecord] =
  var stack: seq[ConditionRecord]
  stack.add rec

  while stack.len > 0:
    let cur = stack.pop
    if isComplete cur:
      result.add cur
      continue

    let firstUnknown = cur.row.find '?'
    assert firstUnknown >= 0 and firstUnknown < cur.row.len
    for alt in ['.', '#']:
      var guess = cur
      guess.row[firstUnknown] = alt
      if check2(guess):
        stack.add guess

let pt1 =
  block:
    var x = 0
    for rec in input:
      x.inc rec.repair.len
    x

echo pt1
