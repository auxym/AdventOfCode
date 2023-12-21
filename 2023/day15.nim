import std/strutils

import regex

func parseInput(txt: string): seq[string] =
  for line in txt.strip.splitlines:
    result.add line.split(",")

let input = readFile("input/day15_input.txt").parseInput
#let input = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7".parseInput

func hash(s: string): int =
  for c in s:
    result.inc c.ord
    result = result * 17
    result = result mod 256

func hashAndSum(steps: seq[string]): int =
  for s in steps:
    result.inc s.hash

let pt1 = hashAndSum input
echo pt1

# Part 2

type
  LensOp = enum
    Remove
    Add

  Instruction = object
    label: string
    op: LensOp
    focalLength: Natural

  Lens = object
    label: string
    focalLength: Natural

  LensBoxArray = array[0..255, seq[Lens]]

func parseInput2(txt: string): seq[Instruction] =
  const exp = re2"([a-z]+)(-|=(\d+))"
  var m: RegexMatch2
  for part in txt.split(","):
    assert part.strip.match(exp, m)
    var ins: Instruction
    ins.label = part[m.group(0)]

    let opText = part[m.group(1)]
    if opText[0] == '=':
      ins.op = Add
      ins.focalLength = part[m.group(2)].parseInt
    elif opText[0] == '-':
      ins.op = Remove
    else:
      assert false

    result.add ins

#let input2 = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7".parseInput2
let input2 = readFile("input/day15_input.txt").parseInput2
#for ins in input2:
#  echo ins

func findLabel(box: seq[Lens]; label: string): int =
  result = -1
  for i in box.low..box.high:
    if box[i].label == label:
      return i

proc apply(boxes: var LensBoxArray; ins: Instruction) =
  let
    boxIdx = ins.label.hash
    lensIdx = boxes[boxIdx].findLabel(ins.label)
  case ins.op
  of Add:
    let l = Lens(label: ins.label, focalLength: ins.focalLength)
    if lensIdx >= 0:
      boxes[boxIdx][lensIdx] = l
    else:
      boxes[boxIdx].add l
  of Remove:
    if lensIdx >= 0:
      boxes[boxIdx].delete lensIdx

proc apply(boxes: var LensBoxArray; instructions: seq[Instruction]) =
  for ins in instructions:
    boxes.apply ins

func power(boxes: LensBoxArray): int =
  for (bi, lenses) in boxes.pairs:
    for (slot, ls) in lenses.pairs:
      result.inc (bi + 1) * (slot + 1) * ls.focalLength

let pt2 =
  block:
    var boxes: LensBoxArray
    boxes.apply input2
    boxes.power

echo pt2
