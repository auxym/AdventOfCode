import std/strutils

import std/sequtils

import std/math

import regex

import utils

type
  Category = enum
    catX
    catM
    catA
    catS

  Part = array[Category, int]

  Operator = enum
    opNone
    opGreaterThan
    opLessThan

  Rule = object
    op: Operator
    lhs: Category
    rhs: int
    truewf: string

  Workflow = object
    id: string
    rules: seq[Rule]

  Input = object
    workflows: Table[string, Workflow]
    parts: seq[Part]

func parseWorkflow(txt: string): Workflow =
  const
    ruleEx = re2"([xmas])([<>])(\d+):([a-zA-Z]+)"
    wfEx = re2"([a-zA-Z]+)\{([^\{\}]+)\}"

  var m: RegexMatch2
  doAssert txt.match(wfEx, m)

  result.id = txt[m.group(0)]

  for part in txt[m.group(1)].split(","):
    if part.match(re2"[a-zA-Z]+"):
      result.rules.add Rule(op: opNone, truewf: part)
    else:
      doAssert part.match(ruleEx, m)
      var rule: Rule

      rule.op =
        case part[m.group(1)][0]
        of '<':
          opLessThan
        of '>':
          opGreaterThan
        else:
          assert false
          opNone

      rule.lhs =
        case part[m.group(0)][0]
        of 'x':
          catX
        of 'm':
          catM
        of 'a':
          catA
        of 's':
          catS
        else:
          assert false
          catX

      rule.rhs = part[m.group(2)].parseInt
      rule.truewf = part[m.group(3)]

      result.rules.add rule

func parsePart(txt: string): Part =
  const partExpr = re2"\{x=(\d+),m=(\d+),a=(\d+),s=(\d+)\}"
  var m: RegexMatch2
  doAssert txt.match(partExpr, m)
  result[catX] = txt[m.group(0)].parseInt
  result[catM] = txt[m.group(1)].parseInt
  result[catA] = txt[m.group(2)].parseInt
  result[catS] = txt[m.group(3)].parseInt

func parseInput(txt: string): Input =
  let blocks = txt.strip.split("\n\n")
  for ln in blocks[0].strip.splitLines:
    let wf = parseWorkflow ln
    result.workflows[wf.id] = wf

  for ln in blocks[1].strip.splitLines:
    result.parts.add ln.parsePart

let input = readFile("input/day19_input.txt").parseInput
#let input = readFile("input/day19_example.txt").parseInput

func eval(rule: Rule; part: Part): bool =
  case rule.op
  of opNone:
    true
  of opLessThan:
    part[rule.lhs] < rule.rhs
  of opGreaterThan:
    part[rule.lhs] > rule.rhs

func process(wf: Workflow; part: Part): string =
  for rule in wf.rules:
    if rule.eval(part):
      return rule.truewf
  assert false

func process(wftab: Table[string, Workflow]; part: Part): bool =
  var next = "in"
  while next != "A" and next != "R":
    let wf = wftab[next]
    next = wf.process(part)
  result = next == "A"

let pt1 = input.parts.filterIt(input.workflows.process(it)).mapIt(sum it).sum
echo pt1
