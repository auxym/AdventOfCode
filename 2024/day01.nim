import std/sequtils
import std/strutils
import std/algorithm
import std/tables
import utils

type Input = (seq[int], seq[int])

func parseInput(s: string): Input =
  for ln in s.strip.splitLines:
    let ints = ln.getInts
    assert ints.len == 2
    result[0].add ints[0]
    result[1].add ints[1]

let input = readFile("./input/day01_input.txt").parseInput

func p1(input: Input): int =
  let sortedIpt = (sorted(input[0]), sorted(input[1]))
  for pair in zip(sortedIpt[0], sortedIpt[1]):
    result.inc abs(pair[0] - pair[1])

echo p1(input)

func p2(input: Input): int =
  let rightCounts = toCountTable input[1]
  for loc in input[0]:
    result.inc loc * rightCounts[loc]

echo p2(input)
