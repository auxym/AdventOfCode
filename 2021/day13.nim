import regex
import std/strutils
import std/sets
import utils

let input = readFile "./input/day13_input.txt"

type DottedPaper = object
  dots: HashSet[Vector]
  height: int
  width: int

type FoldDirection = enum fdX, fdY

type FoldInstruction = object
  direction: FoldDirection
  location: int

func parseInput(s: string): (DottedPaper, seq[FoldInstruction]) =
  let chunks = s.strip().split("\n\n")
  assert chunks.len == 2

  var paper: DottedPaper
  for ln in chunks[0].strip.splitLines:
    let v = ln.parseVector
    paper.dots.incl v
    if v.x > paper.width: paper.width = v.x
    if v.y > paper.height: paper.height = v.y

  var
    ins: seq[FoldInstruction]
    m: RegexMatch
  let insPattern = re"(x|y)=(\d+)"
  for ln in chunks[1].strip.splitLines:
    doAssert ln.find(insPattern, m)
    var i: FoldInstruction
    i.direction =
      case m.group(0, ln)[0]:
        of "x": fdX
        of "y": fdY
        else:
          doAssert false
          fdX
    i.location = m.group(1, ln)[0].parseInt
    ins.add i

  result = (paper, ins)

proc showPaper(p: DottedPaper) =
  for y in 0..p.height:
    var line = newSeqOfCap[char](p.width+1)
    for x in 0..p.width:
      if (x, y) in p.dots:
        line.add '#'
      else:
        line.add ' '
    echo line.join("")

proc fold(paper: DottedPaper, ins: FoldInstruction): DottedPaper =
  discard
  result = paper
  case ins.direction:
  of fdX: result.width = ins.location - 1
  of fdY: result.height = ins.location - 1

  for dot in paper.dots:
    if ins.direction == fdY and dot.y > ins.location:
      let mdot = (dot.x, ins.location - (dot.y - ins.location))
      result.dots.incl mdot
      result.dots.excl dot
    elif ins.direction == fdX and dot.x > ins.location:
      let mdot = (ins.location - (dot.x - ins.location), dot.y)
      result.dots.incl mdot
      result.dots.excl dot

proc foldAll(paper: DottedPaper, ins: seq[FoldInstruction]): DottedPaper =
  result = paper
  for i in ins:
    result = result.fold(i)

let (paper, foldList) = input.parseInput
echo paper.fold(foldList[0]).dots.len
paper.foldAll(foldList).showPaper
