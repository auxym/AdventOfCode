import std/strutils
import std/sequtils
import std/tables

let input = readFile "./input/day14_input.txt"

type InsertionRules = Table[string, char]

type Polymer = object
  paircounts: CountTable[string]
  elemcounts: CountTable[char]

func toPolymer(s: string): Polymer =
  result.elemcounts = s.toCountTable
  for i in 0 ..< s.high:
    let pair = s[i..i+1]
    result.paircounts.inc pair

func parseInput(s: string): (Polymer, InsertionRules) =
  let chunks = s.strip().split("\n\n")
  result[0] = chunks[0].toPolymer

  var rules: InsertionRules
  for line in chunks[1].strip.splitLines:
    let parts = line.split(" -> ")
    assert parts.len == 2
    rules[parts[0].strip] = (parts[1].strip)[0]
  result[1] = rules

func polymerize(poly: Polymer, rules: InsertionRules): Polymer =
  result.elemcounts = poly.elemcounts
  for (pair, count) in poly.paircounts.pairs:
    if pair in rules:
      let insert = rules[pair]
      result.paircounts.inc(pair[0] & insert, count)
      result.paircounts.inc(insert & pair[1], count)
      result.elemcounts.inc(insert, count)
    else:
      result.paircounts.inc(pair, count)


let (startingPoly, rules) = input.parseInput

var newPoly = startingPoly
for i in 1..10:
  newPoly = newPoly.polymerize(rules)
let
  elemCountVals = toSeq(newPoly.elemcounts.values)
  pt1 = elemCountVals.max - elemCountVals.min
echo pt1

var newPoly2 = startingPoly
for i in 1..40:
  newPoly2 = newPoly2.polymerize(rules)
let
  elemCountVals2 = toSeq(newPoly2.elemcounts.values)
  pt2 = elemCountVals2.max - elemCountVals2.min
echo pt2