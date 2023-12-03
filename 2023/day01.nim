import std/sequtils
import std/strutils
import std/math
import regex

let input = readFile("./input/day01_input.txt").strip.splitLines

func recoverCalibration(line: string): Natural =
  let lineDigits = line.filterIt(it in Digits)
  result = parseInt(lineDigits[0] & lineDigits[^1])

let part1 = input.map(recoverCalibration).sum
echo part1

# Part 2

func str2digit(s: string): 0..9 =
  const words = @["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
  if s.len == 1 and s[0] in Digits:
    result = parseInt(s)
  else:
    let idx = words.find s
    assert idx >= 0
    result = idx + 1

func findDigitStrings(s: string): seq[string] =
  const pat = re2"(\d|one|two|three|four|five|six|seven|eight|nine)"
  var
    pos = 0
    m: RegexMatch2
  while find(s, pat, m, pos):
    result.add s[m.boundaries]
    pos = m.boundaries.a + 1

func recoverCalibration2(line: string): Natural =
  let digitStrings = findDigitStrings line
  result = digitStrings[0].str2digit * 10 + digitStrings[^1].str2digit

let part2 = input.map(recoverCalibration2).sum
echo part2
