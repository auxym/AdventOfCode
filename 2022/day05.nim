import ./utils
import std/strutils

type
  Crate = range['A' .. 'Z']

  Stack = seq[Crate]

  StackList = array[1..9, Stack]

  Instruction = object
    n: Natural
    src: range[1..9]
    dst: range[1..9]

func parseInput(s: string): (StackList, seq[Instruction]) =
  let lines = s.strip(leading=false).splitLines

  # Parse stacks
  var resultStacks: StackList
  for lineIdx in countdown(7, 0):
    let line = lines[lineIdx]
    var stackidx = 1
    for col in countup(1, 33, 4):
      let c = line[col]
      if c in 'A' .. 'Z':
        resultStacks[stackidx].add c
      stackidx.inc

  # Parse instructions
  var instructions: seq[Instruction]
  for lineIdx in 10 .. lines.high:
    let ints = lines[lineIdx].getInts
    assert ints.len == 3
    instructions.add Instruction(
      n: ints[0],
      src: ints[1],
      dst: ints[2]
    )

  result = (resultStacks, instructions)

let (inputStacks, inputInstructions) = readFile("./input/day05_input.txt").parseInput

func executeInstructions(stacks: StackList, instructions: seq[Instruction]): StackList =
  result = stacks
  for ins in instructions:
    for i in 0 ..< (ins.n):
      result[ins.dst].add result[ins.src].pop

func getTopCrates(stacks: StackList): string =
  for stk in stacks:
    result.add stk[^1]

proc part1: string =
  executeInstructions(inputStacks, inputInstructions).getTopCrates

echo part1()

# Part 2

func execute9001(stacks: StackList, instructions: seq[Instruction]): StackList =
  result = stacks
  for ins in instructions:
    for i in countdown(ins.n, 1):
      result[ins.dst].add result[ins.src][^i]
    result[ins.src].setLen(result[ins.src].len - ins.n)

proc part2: string =
  execute9001(inputStacks, inputInstructions).getTopCrates

echo part2()
