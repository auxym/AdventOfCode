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

func insertColumn(map: var GalaxiesMap, after: Natural) =
  for gal in map.mitems:
    if gal.x > after:
      inc gal.x

func insertRow(map: var GalaxiesMap, after: Natural) =
  for gal in map.mitems:
    if gal.y > after:
      inc gal.y

func incAfter[T](arr: var openArray[T], after: int) =
  for i in (after + 1) .. arr.high:
    inc arr[i]

func expand(map: GalaxiesMap): GalaxiesMap =
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
    result.insertColumn(after=emptyCols[icol])
    emptyCols.incAfter icol
  for irow in emptyRows.low .. emptyRows.high:
    result.insertRow(after=emptyRows[irow])
    emptyrows.incAfter irow

let input = readFile("input/day11_input.txt").parseInput

let pt1 = block:
  var sd = 0
  for pair in combinations(input.expand, 2):
    sd.inc manhattan(pair[0], pair[1])
  sd

echo pt1
