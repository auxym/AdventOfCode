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

# Part 2

type CommandKind = enum cmdUp, cmdDown, cmdForward

type Command = object
  kind: CommandKind
  value: int

func parseInputLine2(line: string): Command =
  let exp = re"(forward|down|up) (\d+)"
  var m: RegexMatch
  doAssert(line.match(exp, m))

  result.value = m.group(1, line)[0].parseInt()
  result.kind = case m.group(0, line)[0]:
    of "forward":
      cmdForward
    of "down":
      cmdDown
    of "up":
      cmdUp
    else:
      # should never get here
      cmdForward

let commands = readFile("./input/day02_input.txt").strip().splitLines().map(parseInputLine2)

var
  pos: Vector = (0, 0)
  aim = 0

for com in commands:
  case com.kind:
    of cmdForward:
      pos.x.inc com.value
      pos.y.inc (com.value * aim)
    of cmdUp:
      aim.dec com.value
    of cmdDown:
      aim.inc com.value

echo pos
let pt2 = pos.x * pos.y
echo pt2
