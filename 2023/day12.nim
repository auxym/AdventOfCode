import std/strutils

import std/sequtils

import std/math

import std/tables

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

  if rec.row.filterIt(it in {'#', '?'}).len < rec.checksum.sum:
    return false

  for rl in rec.checksum:
    var cur = 0
    while i <= rec.row.high and rec.row[i] == '.':
      inc i
    while i <= rec.row.high and rec.row[i] == '#':
      inc cur
      inc i
      if cur > rl:
        return false
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

# Part 2

func unfold(rec: ConditionRecord): ConditionRecord =
  for i in 0..4:
    if i > 0:
      result.row.add "?"
    result.row.add rec.row
    result.checksum.add rec.checksum

type RecordParser = object
  rec: ConditionRecord
  rowIdx: Natural
  csIdx: Natural

func checksumAtEnd(rp: RecordParser): bool =
  rp.csIdx > rp.rec.checksum.high

func atEnd(rp: RecordParser): bool =
  rp.rowIdx > rp.rec.row.high

func peek(rp: RecordParser): char =
  rp.rec.row[rp.rowIdx]

func consume(rp: var RecordParser): char =
  result = rp.rec.row[rp.rowIdx]
  inc rp.rowIdx

func advanceGround(rp: var RecordParser) =
  while not rp.atEnd and rp.peek == '.':
    discard rp.consume

func consumeSprings(rp: var RecordParser): Natural =
  while (not rp.atEnd) and rp.peek == '#':
    inc result
    discard rp.consume

func tryConsumeChecksum(rp: var RecordParser): bool =
  let backup = rp.rowIdx
  rp.advanceGround
  let springCount = rp.consumeSprings
  if springCount == rp.rec.checksum[rp.csIdx] and (rp.atEnd or rp.peek == '.'):
    inc rp.csIdx
    result = true
  else:
    rp.rowIdx = backup
    result = false

func subtree(rec: ConditionRecord): ConditionRecord =
  var rp = RecordParser(rec: rec)
  while (not rp.checksumAtEnd) and rp.tryConsumeChecksum:
    discard
  result.row = rec.row[rp.rowIdx .. ^1]
  result.checksum = rec.checksum[rp.csIdx .. ^1]

proc countPlausible(
    rec: ConditionRecord; cache: var Table[ConditionRecord, Natural]
): Natural =
  if not rec.check2:
    return 0
  if rec.isComplete:
    return 1

  let firstUnknown = rec.row.find '?'
  assert firstUnknown >= 0 and firstUnknown < rec.row.len
  for alt in ['.', '#']:
    var guess = rec
    guess.row[firstUnknown] = alt
    guess = guess.subtree
    result.inc block:
        if guess in cache:
          cache[guess]
        else:
          let c = countPlausible(guess, cache)
          cache[guess] = c
          c

func countPlausibleMemo(rec: ConditionRecord): Natural =
  var cache: Table[ConditionRecord, Natural]
  result = countPlausible(rec, cache)

let pt2 =
  block:
    var n = 0
    for rec in input:
      n.inc rec.unfold.countPlausibleMemo
    n
echo pt2
