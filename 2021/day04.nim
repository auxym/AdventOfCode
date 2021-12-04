import std/strutils
import std/sequtils
import utils
import std/intsets

type
  BingoCard = seq[seq[int]]
  BingoCardState = seq[seq[bool]]

const CardSize = 5

func parseInput(s: string): (seq[int], seq[BingoCard]) =
  let chunks = s.strip().split("\n\n")
  result[0] = chunks[0].getInts

  for i in 1 .. chunks.high:
    let card: BingoCard = chunks[i].strip().splitLines().map(getInts)
    assert card.len == CardSize
    for row in card: assert row.len == CardSize
    result[1].add card

let (bingoNumbers, bingoCards) = readFile("./input/day04_input.txt").parseInput

iterator rows[T](s: seq[seq[T]]): seq[T] =
  for row in s:
    yield row

iterator columns[T](s: seq[seq[T]]): seq[T] =
  for i in 0 ..< CardSize:
    yield s.mapIt(it[i])

proc update(state: var BingoCardState, card: BingoCard, n: int) =
  for i in 0 ..< CardSize:
    for j in 0 ..< CardSize:
      if card[i][j] == n:
        state[i][j] = true

proc checkWin(state: BingoCardState): bool =
  for rw in state.rows:
    if rw.allIt(it):
      return true

  for col in state.columns:
    if col.allIt(it):
      return true

  return false

func score(card: BingoCard, state: BingoCardState, n: int): int =
  for i in 0 ..< CardSize:
    for j in 0 ..< CardSize:
      if not state[i][j]: result.inc card[i][j]

  result = result * n

func initState(): BingoCardState =
  newSeqWith(CardSize, newSeqWith(CardSize, false))

func playGame(numbers: seq[int], cards: seq[BingoCard]): int =
  var gameState: seq[BingoCardState] = newSeqWith(cards.len, initState())

  for n in numbers:
    for i in 0 .. cards.high:
      gameState[i].update(cards[i], n)
      if gameState[i].checkWin:
        return cards[i].score(gameState[i], n)

let pt1Score = playGame(bingoNumbers, bingoCards)
echo pt1Score
doAssert pt1Score == 63424

# Part 2
func playGameUntilLast(numbers: seq[int], cards: seq[BingoCard]): int =
  var
    gameState: seq[BingoCardState] = newSeqWith(cards.len, initState())
    remainingCards: IntSet

  for i in 0 .. cards.high: remainingCards.incl i

  for n in numbers:
    for i in remainingCards:
      gameState[i].update(cards[i], n)
      if gameState[i].checkWin:
        remainingCards.excl i
      if remainingCards.len == 0:
        return score(cards[i], gameState[i], n)

let lastWinScore = playGameUntilLast(bingoNumbers, bingoCards)
echo lastWinScore
doAssert lastWinScore == 23541
