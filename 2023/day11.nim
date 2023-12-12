import std/strutils

import std/sequtils

import std/enumerate

import std/intsets

import std/algorithm

import utils

type GalaxiesMap = seq[Vector]

func parseInput(txt: string): GalaxiesMap =
  for y, line in enumerate(txt.strip.splitLines):
    for x, c in line.pairs:
      if c == '#':
        result.add (x, y)

func insertColumn(map: var GalaxiesMap, after: Natural, n: Positive = 1) =
  for gal in map.mitems:
    if gal.x > after:
      gal.x.inc n

func insertRow(map: var GalaxiesMap, after: Natural, n: Positive = 1) =
  for gal in map.mitems:
    if gal.y > after:
      gal.y.inc n

func incAfter[T](arr: var openArray[T], after: int, n: T = 1) =
  for i in (after + 1) .. arr.high:
    arr[i].inc n

func expand(map: GalaxiesMap, k: Positive = 2): GalaxiesMap =
  let n = k - 1
  var
    highX, highY = int.low
    rowSet, colSet: IntSet
  for gal in map:
    if gal.x > highX: highX = gal.x
    if gal.y > highY: highY = gal.y
    colSet.incl gal.x
    rowSet.incl gal.y

  var
    emptyCols = toSeq(toSeq(0 .. highX).toIntSet - colSet).sorted
    emptyRows = toSeq(toSeq(0 .. highY).toIntSet - rowSet).sorted

  result = map
  for icol in emptyCols.low .. emptyCols.high:
    result.insertColumn(after=emptyCols[icol], n=n)
    emptyCols.incAfter(icol, n)
  for irow in emptyRows.low .. emptyRows.high:
    result.insertRow(after=emptyRows[irow], n=n)
    emptyrows.incAfter(irow, n)

let input = readFile("input/day11_input.txt").parseInput

let pt1 = block:
  var sd = 0
  for pair in combinations(input.expand(2), 2):
    sd.inc manhattan(pair[0], pair[1])
  sd

echo pt1

let pt2 = block:
  var sd = 0
  for pair in combinations(input.expand(1_000_000), 2):
    sd.inc manhattan(pair[0], pair[1])
  sd

echo pt2
