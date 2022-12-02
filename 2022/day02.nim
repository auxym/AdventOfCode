import std/strutils
import std/sequtils
import std/math
import std/algorithm
import utils

type Move = enum Rock, Paper, Scissor

type Round = object
  opMove: Move
  myMove: Move

func parseRound(ln: string): Round =
  case ln[0]:
  of 'A': result.opMove = Rock
  of 'B': result.opMove = Paper
  of 'C': result.opMove = Scissor
  else: doAssert false

  case ln[2]:
  of 'X': result.myMove = Rock
  of 'Y': result.myMove = Paper
  of 'Z': result.myMove = Scissor
  else: doAssert false

func getScore(r: Round): int =
  let isWin =
    (r.myMove == Rock and r.opMove == Scissor) or
    (r.myMove == Scissor and r.opMove == Paper) or
    (r.myMove == Paper and r.opMove == Rock)

  let isDraw = r.myMove == r.opMove

  let shapeScore = case r.myMove:
    of Rock: 1
    of Paper: 2
    of Scissor: 3

  let winScore =
    if isWin: 6
    elif isDraw: 3
    else: 0

  result = shapeScore + winScore

const inputfile = "./input/day02_input.txt"

let input = readFile(inputfile).strip.splitLines.map(parseRound)

proc part1: int =
  for round in input:
    result.inc round.getScore

echo part1()
