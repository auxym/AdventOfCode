import std/strutils

import std/sequtils

import std/math

import utils

let input = readFile("input/day09_input.txt").splitLines.map(getInts)

func extrapHist(h: seq[int]): int =
  if h.allIt(it == 0):
    return 0

  var diffs = newSeq[int](h.len - 1)
  for i in 0 ..< h.high:
    diffs[i] = h[i + 1] - h[i]
  return h[^1] + extrapHist(diffs)

let pt1 = input.map(extrapHist).sum
echo pt1


func extrapHistBackwards(h: seq[int]): int =
  if h.allIt(it == 0):
    return 0

  var diffs = newSeq[int](h.len - 1)
  for i in 0 ..< h.high:
    diffs[i] = h[i + 1] - h[i]
  return h[0] - extrapHistBackwards(diffs)

let pt2 = input.map(extrapHistBackwards).sum
echo pt2
