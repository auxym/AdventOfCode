import std/strutils

import std/sequtils

import std/algorithm

import std/enumerate

type Card = char

type Hand = array[5, Card]

type HandEntry = object
  hand: Hand
  bid: Natural

type HandKind = enum
  HighCard,
  OnePair,
  TwoPairs,
  ThreeOfAKind,
  FullHouse,
  FourOfAKind,
  FiveOfAKind

const CardRanks = "23456789TJQKA"

func rank(c: Card): Natural =
  let tmp = CardRanks.find(c)
  if tmp < 0:
    raise newException(ValueError, "Invalid card " & $c)
  result = tmp

func cmp(a, b: Card): int =
  cmp(a.rank, b.rank)

func parseInput(txt: string): seq[HandEntry] =
  for line in txt.strip.splitLines:
    let parts = line.split
    var e: HandEntry
    for i in 0 .. 4:
      e.hand[i] = parts[0][i]
    e.bid = parts[1].parseInt
    result.add e

func getKind(hand: Hand): HandKind =
  # Count number of identical cards
  let sh = hand.sorted
  var
    counts: seq[Natural]
    i = 1
    cur = 1
  while i <= sh.high:
    if sh[i] == sh[i - 1]:
      inc cur
    else:
      counts.add cur
      cur = 1
    if i == sh.high:
      counts.add cur
    inc i

  counts.sort(Descending)
  result =
    if counts[0] == 5:
      FiveOfAKind
    elif counts[0] == 4:
      FourOfAKind
    elif counts[0] == 3 and counts[1] == 2:
      FullHouse
    elif counts[0] == 3:
      ThreeOfAKind
    elif counts[0] == 2 and counts[1] == 2:
      TwoPairs
    elif counts[0] == 2:
      OnePair
    else:
      HighCard

func cmp(a, b: Hand): int =
  result = cmp(a.getKind, b.getKind)
  if result != 0: return

  for (cardA, cardB) in zip(a, b):
    result = cmp(cardA, cardB)
    if result != 0: return

#[
let input = """
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
""".parseInput.sortedByIt(it.hand)
]#

let input = readFile("input/day07_input.txt").parseInput.sortedByIt(it.hand)

#for he in input:
#  echo he.hand, " ", he.hand.getKind

let pt1 = block:
  var x = 0
  for (i, ent) in enumerate(input):
    x.inc (i + 1) * ent.bid
  x

echo pt1
