import std/strutils
import std/sequtils
import std/tables
import std/math
import utils

#let inputText = """
#be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
#edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
#fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
#fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
#aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
#fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
#dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
#bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
#egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
#gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
#"""
let inputText = readFile("./input/day08_input.txt")

type Segment = 'a' .. 'g'

type Display = set[Segment]

type PuzzleInputEntry = object
  patterns: seq[Display]
  output: seq[Display]

func toDisplay(s: string): Display =
  for chr in s:
    result.incl chr

func parseInput(s: string): seq[PuzzleInputEntry] =
  for ln in s.strip().splitLines:
    let
      parts = ln.split(" | ")
      pat = parts[0].strip().split(" ").map(toDisplay)
      outp = parts[1].strip().split(" ").map(toDisplay)

    assert pat.len == 10
    assert outp.len == 4
    result.add PuzzleInputEntry(patterns: pat, output: outp)

let input = parseInput inputText

var pt1: int
for entry in input:
  for o in entry.output:
    if o.len in [2, 4, 3, 7]: pt1.inc

echo pt1

# Part 2

func findSegMap(entry: PuzzleInputEntry): Table[Display, int] =
  var intMap: Table[int, Display]
  for pat in entry.patterns:
    if pat.len == 2:
      assert 1 notin intMap
      intMap[1] = pat
    elif pat.len == 3:
      assert 7 notin intMap
      intMap[7] = pat
    elif pat.len == 4:
      assert 4 notin intMap
      intMap[4] = pat
    elif pat.len == 7:
      assert 8 notin intMap
      intMap[8] = pat

  for pat in entry.patterns:
    if pat.len == 6:
      if (pat * intMap[7]).len == 2:
        assert 6 notin intMap
        intMap[6] = pat
      elif (pat * intMap[4]).len == 4:
        assert 9 notin intMap
        intMap[9] = pat
      else:
        assert 0 notin intMap
        intMap[0] = pat

  for pat in entry.patterns:
    if pat.len == 5:
      if (pat * intMap[7]).len == 3:
        assert 3 notin intMap
        intMap[3] = pat
      elif (pat * intMap[4]).len == 3:
        assert 5 notin intMap
        intMap[5] = pat
      else:
        assert 2 notin intMap
        intMap[2] = pat

  for i in 0..9:
    result[intMap[i]] = i

func digitsToInt(digits: seq[int]): int =
  for i in 0 .. digits.high:
    result.inc digits[i] * (10 ^ (digits.high - i))

func decodeOutput(entry: PuzzleInputEntry): int =
  let segMap = findSegMap entry
  result = entry.output.mapIt(segMap[it]).digitsToInt

let pt2 = inputText.parseInput.map(decodeOutput).foldl(a + b)
echo pt2
doAssert pt2 == 1046281
