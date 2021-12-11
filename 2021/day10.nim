import std/tables
import std/strutils
import std/sequtils
import std/algorithm

#[
let input = """
[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]
"""
]#
let input = readFile("./input/day10_input.txt")

let delimTable = toTable {
  '(': ')',
  '[': ']',
  '{': '}',
  '<': '>'
}

let openingDelims = block:
  var s: set[char]
  for c in delimTable.keys: s.incl c
  s

let closingDelims = block:
  var s: set[char]
  for c in delimTable.values: s.incl c
  s

let pointsTable = toTable {
  ')': 3,
  ']': 57,
  '}': 1197,
  '>': 25137,
}

proc evalScore(line: string): int =
  var stack: seq[char]
  for c in line:
    if c in openingDelims:
      stack.add c
    elif c in closingDelims:
      let matching = stack.pop
      if delimTable[matching] != c:
        return pointsTable[c]

let pt1 = input.strip.splitLines.map(evalScore).foldl(a+b)
echo pt1

# Part 2

let compScoreTable = toTable {
  ')': 1,
  ']': 2,
  '}': 3,
  '>': 4,
}

proc completionScore(line: string): int =
  var stack: seq[char]
  for c in line:
    if c in openingDelims:
      stack.add c
    elif c in closingDelims:
      let matching = stack.pop
      assert delimTable[matching] == c

  while stack.len > 0:
    result = result * 5 + compScoreTable[delimTable[stack.pop()]]

proc isNotCorrupt(line: string): bool = line.evalScore == 0

let pt2AllScores = input
  .strip
  .splitLines
  .filter(isNotCorrupt)
  .map(completionScore)
  .sorted

echo pt2AllScores[pt2AllScores.len div 2]
