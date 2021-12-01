import utils

let input = readFile("./input/day01_input.txt").getInts

var incCount = 0
for i in 1..input.high:
  if input[i] > input[i-1]:
    incCount.inc

doAssert incCount == 1752
echo incCount
