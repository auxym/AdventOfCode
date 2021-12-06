import utils
import std/sequtils

#let input = "3,4,3,1,2"
let input = readFile("./input/day06_input.txt")

type SchoolState = array[0..8, int]

func initFishes(s: string): SchoolState =
  for x in s.getInts:
    result[x].inc

proc step(st: var SchoolState) =
  let numReproduce = st[0]
  for i in 0 .. st.high:
    if i > 0:
      st[i - 1].inc st[i]
    st[i] = 0

  st[6].inc numReproduce
  st[8].inc numReproduce

var pt1State = input.initFishes
for i in 1..80:
  pt1State.step

let pt1count = pt1State.foldl(a+b)
echo pt1count
doAssert pt1count == 393019

# Part 2
var pt2State = input.initFishes
for i in 1..256:
  pt2State.step

let pt2count = pt2State.foldl(a+b)
echo pt2count
doAssert pt2count == 1757714216975
