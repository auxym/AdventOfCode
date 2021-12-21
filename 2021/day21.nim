import memo # https://github.com/andreaferretti/memo

type DeterministicDie = object
  sides: int
  state: int

proc roll(d: var DeterministicDie, n: int): int =
  for i in 0 ..< n:
    d.state.inc
    result.inc d.state
    d.state = d.state mod d.sides

func playGame(p1start, p2start: int): int =
  const numRollsPerTurn = 3
  var
    p1State = p1start - 1
    p2State = p2start - 1
    p1Score, p2Score, rolls: int
    die = DeterministicDie(sides: 100)

  while true:
    p1State = (p1State + die.roll(numRollsPerTurn)) mod 10
    p1Score.inc p1State + 1
    rolls.inc numRollsPerTurn
    if p1Score >= 1000: break

    p2State = (p2State + die.roll(numRollsPerTurn)) mod 10
    p2Score.inc p2State + 1
    rolls.inc numRollsPerTurn
    if p2Score >= 1000: break

  let loserScore = if p1Score >= 1000: p2Score else: p1Score
  result = loserScore * rolls

# Example
#echo playGame(4, 8)

echo playGame(8, 9)

# Part 2

type Player = enum p1, p2

func next(p: Player): Player =
  if p == p1: p2 else: p1

type GameState = object
  player: Player
  pos: array[Player, 0..9]
  score: array[Player, int]
  dieSum: int
  roll: 0..3

const DiracSides = 3

func playDiracRec(g: GameState, rollval: int): array[Player, int] {.memoized.} =
  #debugEcho g
  var newGame = g
  let p = newGame.player
  newGame.dieSum.inc rollval
  newGame.roll.inc
  if newGame.roll == 3:
    newGame.pos[p] = (newGame.pos[p] + newGame.dieSum) mod 10
    newGame.score[p].inc newGame.pos[p] + 1
    newGame.roll = 0
    newGame.dieSum = 0
    newGame.player = newGame.player.next
    
  if newGame.score[p] >= 21:
    result[p] = 1
  else:
    for nextRoll in 1 .. DiracSides:
      let winCounts = playDiracRec(newGame, nextRoll)
      result[p1].inc winCounts[p1]
      result[p2].inc winCounts[p2]

proc playDirac(p1start, p2start: 1..10): array[Player, int] =
  let
    p1pos: 0..9 = p1start - 1
    p2pos: 0..9 = p2start - 1
  var game = GameState(
    player: p1,
    pos: [p1pos, p2pos],
    score: [0, 0],
    dieSum: 0,
    roll: 0,
  )
  for nextRoll in 1 .. DiracSides:
    let winCounts = playDiracRec(game, nextRoll)
    result[p1].inc winCounts[p1]
    result[p2].inc winCounts[p2]

# Example
#echo playDirac(4, 8)

echo playDirac(8, 9).max
