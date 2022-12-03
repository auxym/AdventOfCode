import std/strutils
import std/sequtils
import ./utils

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

func getScore(myMove, opMove: Move): int =
  let isWin =
    (myMove == Rock and opMove == Scissor) or
    (myMove == Scissor and opMove == Paper) or
    (myMove == Paper and opMove == Rock)

  let isDraw = myMove == opMove

  let winScore =
    if isWin: 6
    elif isDraw: 3
    else: 0

  let shapeScore = case myMove:
    of Rock: 1
    of Paper: 2
    of Scissor: 3

  result = shapeScore + winScore

func getScore(r: Round): int =
  getScore(r.myMove, r.opMove)

const inputfile = "./input/day02_input.txt"

let input = readFile(inputfile)
            .strip
            .splitLines
            .map(parseRound)

proc part1: int =
  for round in input:
    result.inc round.getScore

echo part1()

# Part 2

type
  RoundResult = enum Loss, Draw, Win

  Round2 = object
    opMove: Move
    result: RoundResult

func parseRound2(ln: string): Round2 =
  case ln[0]:
  of 'A': result.opMove = Rock
  of 'B': result.opMove = Paper
  of 'C': result.opMove = Scissor
  else: doAssert false

  case ln[2]:
  of 'X': result.result = Loss
  of 'Y': result.result = Draw
  of 'Z': result.result = Win
  else: doAssert false

func getScore(r: Round2): int =
  let myMove = case r.result:
  of Loss: r.opMove.cycleBackwards
  of Draw: r.opMove
  of Win: r.opMove.cycle
  result = getScore(myMove, r.opMove)

let part2Input =
  inputfile
  .readFile
  .strip
  .splitLines
  .map(parseRound2)

proc part2(): int =
  for r in part2Input:
    result.inc r.getScore

echo part2()
