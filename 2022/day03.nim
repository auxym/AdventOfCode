import std/strutils
import std/sequtils
import ./utils

type Rucksack = object
  cpt1, cpt2: set[char]

proc parseInput(fname: string): seq[Rucksack] =
  for ln in readFile(fname).strip.splitLines:
    doAssert ln.len mod 2 == 0
    let mid = ln.len div 2
    var rs: Rucksack
    for i in 0 ..< mid:
      rs.cpt1.incl ln[i]
    for i in mid ..< (ln.len):
      rs.cpt2.incl ln[i]
    result.add rs

let input = parseInput "./input/day03_input.txt"

func priority(c: char): int =
  case c:
  of 'a' .. 'z':
    result = c.ord - 'a'.ord + 1
  of 'A' .. 'Z':
    result = c.ord - 'A'.ord + 27
  else:
    doAssert false

proc part1: int =
  for rs in input:
    let inter = rs.cpt1 * rs.cpt2
    doAssert inter.card == 1
    result.inc inter.peek.priority

echo part1()

proc part2: int =
  for g in input.groups(3):
    doAssert g.len == 3
    let badge = g.mapIt(it.cpt1 + it.cpt2).foldl(a * b)
    assert badge.card == 1
    result.inc badge.peek.priority

echo part2()
