import ./utils
import std/strutils

type
  SectionID = int

  PairAssignment = object
    elf1, elf2: Slice[SectionID]

proc parseInput(s: string): seq[PairAssignment] =
  for line in s.strip.splitLines:
    let lineInts = line.getPositiveInts
    doAssert lineInts.len == 4
    result.add PairAssignment(
      elf1: lineInts[0] .. lineInts[1],
      elf2: lineInts[2] .. lineInts[3]
    )

let input = parseInput readFile("./input/day04_input.txt")

proc contains[T: Ordinal](x, sub: Slice[T]): bool =
  return x.a <= sub.a and x.b >= sub.b

proc part1: int =
  for entry in input:
    if (entry.elf1 in entry.elf2) or (entry.elf2 in entry.elf1):
      result.inc

echo part1()

proc part2: int =
  for entry in input:
    if (entry.elf2.a in entry.elf1) or (entry.elf2.b in entry.elf1) or
    (entry.elf1.a in entry.elf2) or (entry.elf1.b in entry.elf2):
      result.inc

echo part2()
