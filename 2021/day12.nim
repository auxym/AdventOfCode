import std/strutils
import std/sequtils
import std/sets
import std/tables
import std/hashes
import utils

#let input = """
#start-A
#start-b
#A-c
#A-b
#b-d
#A-end
#b-end
#"""
let input = readFile "./input/day12_input.txt"

type CaveKind = enum ckLarge, ckSmall, ckStart, ckEnd

type CaveGraph = Table[string, HashSet[string]]

func kind(s: string): CaveKind =
  if s == "start":
    result = ckStart
  elif s == "end":
    result = ckEnd
  elif s == s.toUpperAscii:
    result = ckLarge
  else:
    result = ckSmall

func parseInput(s: string): CaveGraph =
  for line in s.strip.splitLines:
    let parts = line.split("-")
    assert parts.len == 2

    if parts[0] in result:
      result[parts[0]].incl parts[1]
    else:
      result[parts[0]] = toHashSet([parts[1]])

    if parts[1] in result:
      result[parts[1]].incl parts[0]
    else:
      result[parts[1]] = toHashSet([parts[0]])

func findPathsPart1(g: CaveGraph): Natural =
  var stack: seq[seq[string]]
  for nb in g["start"]:
    stack.add @["start", nb]

  while stack.len > 0:
    let
      curPath = stack.pop
      curNode = curPath[^1]
    for neighbor in g[curNode]:
      case neighbor.kind:
      of ckLarge:
        stack.add curPath & neighbor
      of ckSmall:
        if neighbor notin curPath:
          stack.add curPath & neighbor
      of ckEnd:
        result.inc
        #debugEcho join(curPath & neighbor, ",")
      of ckStart:
        discard

let cave = input.parseInput
echo cave.findPathsPart1

#Part 2

func containsTwoSmall(path: seq[string]): bool =
  # Path contains two occurences of small cave
  for e in path:
    if e.kind == ckSmall and path.count(e) > 1:
      return true

func findPathsPart2(g: CaveGraph): Natural =
  var stack: seq[seq[string]]
  for nb in g["start"]:
    stack.add @["start", nb]

  while stack.len > 0:
    let
      curPath = stack.pop
      curNode = curPath[^1]
    for neighbor in g[curNode]:
      case neighbor.kind:
      of ckLarge:
        stack.add curPath & neighbor
      of ckSmall:
        if (neighbor notin curPath) or (not curPath.containsTwoSmall):
          stack.add curPath & neighbor
      of ckEnd:
        result.inc
        #debugEcho join(curPath & neighbor, ",")
      of ckStart:
        discard

echo cave.findPathsPart2
