import std/strutils
import std/sequtils
import std/math
import std/algorithm
import utils

const inputfile = "./input/day01_input.txt"

let input = readFile(inputfile).split("\n\n").mapIt(it.getInts)

proc part1: int =
  for elf in input:
    let totalCals = sum(elf)
    if totalCals > result:
      result = totalCals

proc part2: int =
  let totalCals = input.mapIt(sum(it)).sorted
  result = totalCals[^3 .. ^1].sum

echo part1()
echo part2()
