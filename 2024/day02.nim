import std/sequtils
import std/strutils
import utils

type Input = seq[seq[int]]

func parseInput(s: string): Input =
  for ln in s.strip.splitLines:
    let levels = ln.getInts
    assert levels.len > 1
    result.add levels

let input = readFile("./input/day02_input.txt").parseInput

func diff(x: seq[int]): seq[int] =
  result = newSeqOfCap[int](x.len - 1)
  for i in 1..<x.len:
    result.add x[i] - x[i - 1]

func isSafe(report: seq[int]): bool =
  let diffs = diff report
  (allIt(diffs, it > 0) or allIt(diffs, it < 0)) and allIt(diffs, abs(it) in 1..3)

let p1 = input.filter(isSafe).len
echo p1

func isSafeP2(report: seq[int]): bool =
  if report.isSafe:
    return true
  for i in 0..<report.len:
    var damp = report
    damp.delete(i)
    if damp.isSafe:
      return true
  return false

let p2 = input.filter(isSafeP2).len
echo p2
