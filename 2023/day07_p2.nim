import std/strutils

import std/sequtils

import std/algorithm

import std/tables

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

const CardRanks = "J23456789TQKA"

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
  # Get count of each card type, jokers separately
  var ctab = hand.toCountTable
  let jokerCount = ctab.getOrDefault('J', 0)
  ctab.del 'J'

  var counts = toSeq(ctab.values) & @[0, 0]
  counts.sort(Descending)

  # Add jokers to highest count
  counts[0].inc jokerCount

  let (first, second) = (counts[0], counts[1])
  result =
    if first == 5:
      FiveOfAKind
    elif first == 4:
      FourOfAKind
    elif first == 3 and second == 2:
      FullHouse
    elif first == 3:
      ThreeOfAKind
    elif first == 2 and second == 2:
      TwoPairs
    elif first == 2:
      OnePair
    else:
      HighCard

func cmp(a, b: Hand): int =
  result = cmp(a.getKind, b.getKind)
  if result != 0: return

  for (cardA, cardB) in zip(a, b):
    result = cmp(cardA, cardB)
    if result != 0: return


let input = readFile("input/day07_input.txt").parseInput.sortedByIt(it.hand)

let ans = block:
  var x = 0
  for (i, ent) in input.pairs:
    x.inc (i + 1) * ent.bid
  x

echo ans
