import regex
import utils
import std/strutils
import std/sequtils

func parseInputLine(line: string): Vector =
  let exp = re"(forward|down|up) (\d+)"
  var m: RegexMatch
  doAssert(line.match(exp, m))

  let value = m.group(1, line)[0].parseInt()
  result = case m.group(0, line)[0]:
    of "forward":
      (value, 0)
    of "down":
      (0, value)
    of "up":
      (0, -value)
    else:
      # should never get here
      (0, 0)

let input = readFile("./input/day02_input.txt").strip().splitLines().map(parseInputLine)

let finalPosition = input.foldl(a + b)
let pt1 = finalPosition.x * finalPosition.y
echo pt1
doAssert pt1 == 1882980
