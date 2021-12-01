import utils

let input = readFile("./input/day01_input.txt").getInts

var incCount = 0
for i in 1..input.high:
  if input[i] > input[i-1]:
    incCount.inc

doAssert incCount == 1752
echo incCount

func windowSum(elems: seq[int], at: Natural, wsize: Natural): int = 
  for j in at ..< (at + wsize):
    result.inc elems[j]

func countWindowed(elems: seq[int], wsize: Natural): int =
  var
    curWindow: int
    prevWindow: int

  for i in 0 .. (elems.len - wsize):
    curWindow = windowSum(elems, i, wsize)

    if i == 0:
      continue

    if curWindow > prevWindow:
      result.inc
    prevWindow = curWindow

let pt2 = countWindowed(input, 3)
echo pt2
doAssert pt2 == 1781
