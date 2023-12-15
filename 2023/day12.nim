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

func check(rec: ConditionRecord): bool =
  type RlState = enum
    Ground
    Spring

  result = true
  var
    rl = 0
    cksumIndex = -1
    state = Ground
  for c in rec.row & '.':
    case state
    of Ground:
      if c == '#':
        state = Spring
        rl = 1
        inc cksumIndex
        #debugEcho "Transition spring cki=", cksumIndex
        if cksumIndex > rec.checksum.high:
          return false
      elif c == '?':
        return true
    of Spring:
      if c == '#':
        rl.inc
        if rl > rec.checksum[cksumIndex]:
          return false
      elif c == '?':
        return true
      elif c == '.':
        if rl != rec.checksum[cksumIndex]:
          return false
        state = Ground

  # Ensure we have checked all runlengths
  result = cksumIndex == rec.checksum.high

func isComplete(rec: ConditionRecord): bool =
  '?' notin rec.row

func repair(rec: ConditionRecord): seq[ConditionRecord] =
  var stack: seq[ConditionRecord]
  stack.add rec

  while stack.len > 0:
    let cur = stack.pop
    if isComplete cur:
      result.add cur
      #debugEcho cur
      continue

    let firstUnknown = cur.row.find '?'
    assert firstUnknown >= 0 and firstUnknown < cur.row.len
    for alt in ['.', '#']:
      var guess = cur
      guess.row[firstUnknown] = alt
      if check(guess):
        stack.add guess

let pt1 = block:
  var x = 0
  for rec in input:
    x.inc rec.repair.len
  x

echo pt1

#const a = ConditionRecord(row: "#.#.###", checksum: @[1, 1, 3])
#echo check(a)
