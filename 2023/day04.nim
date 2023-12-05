import std/[strutils, sequtils, math, enumerate, intsets]

import utils

type ScratchCard = object
  id: int
  winningNums: IntSet
  haveNums: IntSet

func parseInput(txt: string): seq[ScratchCard] =
  for line in txt.strip.splitLines:
    var card: ScratchCard
    let parts = line.split(": ")
    card.id = parts[0].split(" ")[^1].strip.parseInt

    let
      numParts = parts[1].split("|")
      winNumbers = numParts[0].getInts
      haveNumbers = numParts[1].getInts

    card.winningNums = toIntSet winNumbers
    card.haveNums = toIntSet haveNumbers

    assert winNumbers.len == card.winningNums.card
    assert haveNumbers.len == card.haveNums.card
    #debugEcho card.id, ": ", card.winningNums, " | ", card.haveNums

    result.add card

func scoreCard(card: ScratchCard): Natural =
  let inter = card.winningNums * card.haveNums
  if inter.card == 0:
    result = 0
  else:
    result = 1 shl (inter.card - 1)

let inputCards = readFile("./input/day04_input.txt").parseInput

let pt1 = inputCards.map(scoreCard).sum
echo pt1
