import std/strutils
import std/sets
import utils

type Image = object
  grid: HashSet[Vector]
  inverted: bool

func `[]`(i: Image, v: Vector): bool =
  result = v in i.grid
  if i.inverted: result = not result

proc `[]=`(i: var Image, v: Vector, x: bool) =
  let x = if i.inverted: not x else: x
  if x:
    i.grid.incl v
  else:
    i.grid.excl v

iterator pairs(img: Image): (Vector, bool) =
  for v in img.grid:
    yield (v, img[v])

func findBounds(img: Image): tuple[upperLeft, lowerRight: Vector] =
  var
    minX, minY = int.high
    maxX, maxY = int.low

  for (v, val) in img.pairs:
    if v.x < minX:
      minX = v.x
    elif v.x > maxX:
      maxX = v.x
    if v.y < minY:
      minY = v.y
    elif v.y > maxY:
      maxY = v.y

  result = ((minX - 2, minY - 2), (maxX + 2, maxY + 2))

proc show(img: Image) =
  let bounds = img.findBounds
  for row in bounds.upperLeft.y .. bounds.lowerRight.y:
    var line = ""
    for col in bounds.upperLeft.x .. bounds.lowerRight.x:
      let c = if img[(col, row)]: '#' else: '.'
      line = line & c
    echo line
  echo ""

func parseInput(s: string): (string, Image) =
  let chunks = s.strip().split("\n\n")
  result[0] = chunks[0].strip()
  assert chunks.len == 2
  assert result[0].len == 512

  let lines = chunks[1].strip().splitLines()
  for (irow, line) in lines.pairs:
    for (icol, chr) in line.pairs:
      if chr == '#':
        result[1][(icol, irow)] = true

func getNeighborCode(img: Image, at: Vector): 0..511 =
  for yoff in -1..1:
    for xoff in -1..1:
      result = result shl 1
      if img[at + (xoff, yoff)]: result.inc

func enhance(img: Image, code: string): Image =
  if code[0] == '#':
    result.inverted = not img.inverted
  else:
    result.inverted = img.inverted

  let bounds = img.findBounds
  for row in bounds.upperLeft.y .. bounds.lowerRight.y:
    for col in bounds.upperLeft.x .. bounds.lowerRight.x:
      let indexCode = img.getNeighborCode((col, row))
      result[(col, row)] = (code[indexCode] == '#')

func countLit(img: Image): int =
  for (v, px) in img.pairs:
    if px: result.inc

let (enhanceStr, inputImage) = readFile("./input/day20_input.txt").parseInput
#let (enhanceStr, inputImage) = """
#..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..###..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#..#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#......#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.....####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.......##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#
#
##..#.
##....
###..#
#..#..
#..###
#""".parseInput

# Part 1
block:
  var m = inputImage
  for i in 1..2: m = m.enhance(enhanceStr)
  echo m.countLit

# Part 2
block:
  var m = inputImage
  for i in 1..50: m = m.enhance(enhanceStr)
  echo m.countLit
