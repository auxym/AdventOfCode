import std/strutils

import std/sequtils

import std/tables

import std/math

import regex

import itertools

import utils

type NetworkNode = object
  id, L, R: string

type Network = TableRef[string, NetworkNode]

type Documents = object
  instructions: string
  network: Network

func addNode(g: var Network, id, L, R: string) =
  g[id] = NetworkNode(id: id, L: L, R: R)

func parseInput(txt: string): Documents =
  let lines = txt.strip.splitLines
  result.instructions = lines[0]

  result.network = newTable[string, NetworkNode](1024)
  for i in 2 .. lines.high:
    let ln = lines[i]
    var labels: seq[string]
    for match in ln.findAll(re2"[A-Z0-9]{3}"):
      labels.add ln[match.boundaries]
    assert labels.len == 3

    result.network.addNode(id=labels[0], L=labels[1], R=labels[2])

let docs = readFile("input/day08_input.txt").parseInput

let pt1 = block:
  var
    cur = docs.network["AAA"]
    steps = 0
  for direction in docs.instructions.cycle:
    assert direction in {'L', 'R'}
    cur = docs.network[if direction == 'L': cur.L else: cur.R]
    inc steps
    if cur.id == "ZZZ":
      break
  steps

echo pt1

# Part 2

func solvePart2(docs: Documents): Natural =
  var
    steps = 0
    cur = toSeq(docs.network.values).filterIt(it.id[^1] == 'A')
    periods: seq[Natural]

  for direction in docs.instructions.cycle:
    inc steps
    var
      newCur = newSeqOfCap[NetworkNode](cur.len)
      perFlag = false
    for i in cur.low .. cur.high:
      let nodeNext = docs.network[if direction == 'L': cur[i].L else: cur[i].R]
      if nodeNext.id[^1] == 'Z':
        periods.add steps
        perFlag = true
      else:
        newCur.add nodeNext

    if newCur.len == 0:
      break
    cur = newCur

  result = periods.foldl(lcm(a, b))

echo solvePart2(docs)
